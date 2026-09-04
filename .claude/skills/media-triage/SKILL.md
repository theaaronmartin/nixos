---
name: media-triage
description: Diagnose the NIXCORE media stack — Jellyfin, Radarr, Sonarr, SABnzbd, Navidrome, Audiobookshelf. Use when a service fails to start, cannot read or write media, will not transcode, or shows wrong metadata. Triggers on "jellyfin", "radarr", "sonarr", "sabnzbd", "navidrome", "audiobookshelf", "transcode", "mergerfs", "permission denied" on /mnt/media.
---

# Media stack triage (NIXCORE)

All of it is declared in `modules/media.nix`, NIXCORE only. Storage comes from `modules/storage.nix`:
`/mnt/media_01` and `/mnt/media_02` are the real disks, `/mnt/media` is a **MergerFS union** over
them. `/mnt/games` is separate.

Work through these in order — the causes are ranked by how often they are actually to blame.

## 1. Read the logs before theorising

```bash
journalctl -u <service> -n 50 --no-pager
systemctl status <service> --no-pager
```

Service names are the plain ones: `jellyfin`, `radarr`, `sonarr`, `sabnzbd`, `navidrome`,
`audiobookshelf`.

## 2. Permissions — the usual culprit

Every media service runs as group **`media`, GID 989** (`lib.mkForce`d in `media.nix`, and `plague`
is a member via `users.nix`). Two independent things must both hold:

```bash
# the service is actually in the group
systemctl show <service> -p Group -p SupplementaryGroups

# the files allow it
ls -l /mnt/media/<path>
stat -c '%U %G %a %n' /mnt/media/<path>
```

If a new service cannot see media, the fix is usually adding it to `users.groups.media.members` in
`media.nix` — not loosening file modes.

## 3. systemd hardening — the second usual culprit

NixOS ships these units hardened in ways that block `/mnt`. `media.nix` overrides that with
`lib.mkForce`, and a service that regressed has almost always lost one of these:

- `ProtectSystem = lib.mkForce "soft"`
- `ProtectHome = lib.mkForce false`
- `ReadWritePaths` listing the media paths it needs
- `Group = lib.mkForce "media"`

Compare the running unit against the module — the generated unit is the source of truth for what is
actually in effect:

```bash
systemctl cat <service> | grep -E 'Protect|ReadWrite|Group|DeviceAllow|PrivateDevices'
```

## 4. Jellyfin GPU transcoding

Jellyfin needs device access that the default NixOS unit denies. `media.nix` sets
`DeviceAllow = lib.mkForce [...]` and `PrivateDevices = lib.mkForce false`. If transcoding fails:

```bash
nvidia-smi                                              # is the GPU visible and not saturated?
systemctl cat jellyfin | grep -E 'DeviceAllow|PrivateDevices'
journalctl -u jellyfin -n 100 --no-pager | grep -i -E 'ffmpeg|nvenc|cuda|transcode'
```

Remember the 3080 has only 10 GB and may be holding an Ollama model — see the `ollama-model` skill.
`ollama ps` shows what is resident; a loaded 8 GB model leaves very little for NVENC.

## 5. Inspect the actual file

Codec or container problems look like service problems:

```bash
ffprobe -hide_banner '/mnt/media/<path to file>'
```

## 6. MergerFS-specific gotchas

- **MergerFS does not expose birth time.** Anything relying on file creation date gets nonsense.
  This caused the Jellyfin date-added breakage repaired on 2026-09-01, where a DateAdded plugin
  wrote year-0001 dates for 292 items. If metadata dates look wrong, suspect the union filesystem
  before suspecting the library scan.
- Check which underlying disk a path resolves to before blaming the pool, and watch for a full
  branch — `/mnt/media_02` has run to 99%:

```bash
df -hT /mnt/media /mnt/media_01 /mnt/media_02
```

## 7. Reachability

`media.nix` opens port 8000 explicitly; other services are reached via the Nginx Proxy Manager
container in `modules/proxy.nix`. If a service is up but unreachable, check the proxy before the
firewall:

```bash
ss -ltnp | grep -E '8096|7878|8989|4533|8000'
docker ps
```

## Restarting

A restart needs sudo, which `plague` does not have passwordlessly — hand the command to the user:

```bash
sudo systemctl restart <service>
```

Do not reach for a `nixos-rebuild switch` to restart a service; only use that when `media.nix`
itself changed. See the `nixos-rebuild` skill.
