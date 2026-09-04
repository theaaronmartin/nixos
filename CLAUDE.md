# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is the **canonical reference** for how this repo is laid out. `AGENTS.md` covers agent
behaviour only and deliberately does not restate any of the facts below — keep it that way, because
the two files previously duplicated this material and drifted apart.

## Key Commands

```bash
# Apply config changes to the running system
sudo nixos-rebuild switch --flake ~/nixos#NIXCORE   # or #SHELL

# Shorthand alias (home.nix, host-conditional: resolves to the current host's target)
nix-switch

# Evaluate without building or switching — needs no sudo, catches eval errors cheaply
nixos-rebuild dry-build --flake ~/nixos#NIXCORE

# Build without switching
sudo nixos-rebuild build --flake ~/nixos#NIXCORE

# Roll back the last switch
sudo nixos-rebuild switch --rollback

# Check flake for errors
nix flake check

# Garbage collect old generations
sudo nix-collect-garbage -d   # alias: nix-clean
```

`nix-switch` is defined once per host in `home.nix` under `lib.mkIf (osConfig.networking.hostName == ...)`,
so the same command name does the right thing on either machine. There is no `nixcore-switch` or
`shell-switch`.

**`plague` does not have passwordless sudo.** An agent working over SSH cannot run `switch` itself —
hand the command to the user rather than trying. `dry-build` does not need sudo, so always validate
that way first.

## Architecture

Multi-host NixOS flake for two x86_64-linux machines:

- **NIXCORE** — desktop. AMD CPU, RTX 3080 (proprietary NVIDIA), media/LLM server.
- **SHELL** — Dell Precision 3490 laptop. Core Ultra 5 135H (Meteor Lake), Intel Arc iGPU
  (Xe-LPG, no dGPU). **Bare metal since 2026-09-01**; it was previously a NixOS-WSL config.
  The old WSL profile is no longer on disk — it survives only in git history
  (`hosts/SHELL/hardware-configuration.nix.wsl.bak` and `modules/wsl.nix`, last present at
  `bb5fba5`). Do not reintroduce `wsl.nix` — it force-disabled NetworkManager and the firewall.

**Flake inputs:**
- `nixpkgs` → `nixos-25.11` (stable) — most system packages
- `nixpkgs-unstable` — exposed as `pkgs-unstable` via `specialArgs`, for packages needing newer versions
- `home-manager` → `release-25.11` — user-level config for `plague`
- `nixos-hardware` — SHELL imports `dell-precision-3490-intel`
- `nix-citizen` — Star Citizen runner
- `sops-nix` — secrets

**Entry points:**
- `flake.nix` — inputs plus `nixosConfigurations.NIXCORE` and `nixosConfigurations.SHELL`
- `hosts/NIXCORE/default.nix`, `hosts/SHELL/default.nix` — per-host imports and hardware overrides
- `home.nix` — shared home-manager config for `plague`: aliases, dotfile symlinks, user packages

**Shared modules** (`modules/`):

| File | Purpose | Hosts |
|------|---------|-------|
| `audio.nix` | PipeWire (JACK + ALSA + Pulse), low-latency tuning, DecentSampler, NI zone FHS env, PAM real-time limits | both |
| `base.nix` | Common system packages, zsh enablement | both |
| `boot.nix` | systemd-boot | both |
| `desktop.nix` | KDE Plasma 6 + SDDM, Firefox, Vesktop autostart unit | both |
| `dev.nix` | Developer tools, direnv | both |
| `docker.nix` | Docker engine. Split from `network.nix` 2026-09-01 so a host can run containers without the reverse proxy | both |
| `games.nix` | Steam, GameMode, Lutris, ProtonUp, Starsector FHS wrapper. Hardcodes `/mnt/games/starsector` | NIXCORE |
| `hardware.nix` | Shared graphics enablement, udev rules | both |
| `hm-dev.nix` | Home-manager dev env: Neovim, WezTerm, Starship | both |
| `laptop.nix` | Laptop hardware + power policy, IIO sensors, firmware | SHELL |
| `locale.nix` | Timezone (`America/Los_Angeles`) and locale | both |
| `media.nix` | Jellyfin (NVIDIA HW accel override), Radarr, Sonarr, SABnzbd, Navidrome, Audiobookshelf — all in the `media` group (GID 989) | NIXCORE |
| `mobile-dev.nix` | Android / React Native / Expo toolchain, `programs.adb` | SHELL |
| `network.nix` | NetworkManager, OpenSSH, minimal firewall | both |
| `openrgb.nix` | OpenRGB service, ee1004 unbind workaround, boot color oneshot | NIXCORE |
| `ollama.nix` | Ollama CUDA service **and** the `pi` coding agent that consumes it — see "Local LLMs" below | NIXCORE |
| `power-desktop.nix` | Desktop power policy / performance governor. Split from `hardware.nix` 2026-09-01 so it stops following SHELL | NIXCORE |
| `proxy.nix` | Nginx Proxy Manager OCI container. Split from `network.nix` 2026-09-01 | NIXCORE |
| `security.nix` | YubiKey (yubioath, pcscd, udev rules) | both |
| `sops.nix` | Base secrets: age key + the two API keys `home.nix` reads in zsh init | both |
| `sops-media.nix` | Media-stack secrets and rendered config. Split from `sops.nix` 2026-09-01 | NIXCORE |
| `star-citizen.nix` | Star Citizen runner from nix-citizen, sysctl tuning | NIXCORE |
| `storage.nix` | Mounts for `/mnt/media_01`, `/mnt/media_02`, `/mnt/games`; MergerFS pool at `/mnt/media`; udisks2 | NIXCORE |
| `syncthing.nix` | Declarative Syncthing devices and folders | both |
| `tui.nix` | Terminal/TUI packages | both |
| `users.nix` | `plague` user, group memberships, SSH agent | both |
| `work.nix` | Work packages (teams-for-linux, etc.) | SHELL |
| `pkgs/` | Local package definitions — currently the pinned `libfprint-2-tod1-broadcom-cv3plus` driver | SHELL |

Several modules were split apart on 2026-09-01 and carry header comments explaining exactly why.
**Those comments are authoritative** — read the top of a module before changing it.

**Dotfiles** (`dotfiles/`): Neovim and WezTerm configs are symlinked (not copied) into `~/.config`
via `mkOutOfStoreSymlink`, so edits take effect immediately without rebuilding. Starship config is
read at build time with `builtins.readFile`.

## Important Patterns

- **Two package sets:** `pkgs` for stable, `pkgs-unstable` (via `specialArgs`/`extraSpecialArgs`) for
  anything needing a newer version.
- **Media group:** all media services share GID 989 (`media`). When adding one, add it to
  `users.groups.media.members` in `media.nix`.
- **Jellyfin NVIDIA HW accel:** the `systemd.services.jellyfin.serviceConfig` overrides in
  `media.nix` are required for GPU transcoding — NixOS's default service locks down device access.
- **OpenRGB boot sequence:** the ee1004 unbind must run before OpenRGB starts, and color-setting
  after with a 5s delay. Enforced with `before`/`after` in the unit definitions.
- **`lib.mkForce`:** used throughout `media.nix` to override systemd hardening that would block
  media paths.
- **Secrets are sops-nix, not env files.** Declared in `sops.nix` / `sops-media.nix` from
  `secrets/secrets.yaml`, decrypted to `/run/secrets/<name>` with the age key at
  `~/.config/sops/age/keys.txt`. `home.nix` unconditionally `cat`s `/run/secrets/anthropic_key` and
  `/run/secrets/deepseek_key` in zsh init, so **the age keyfile must be on a fresh machine before
  the first rebuild** or activation fails and every new shell throws. There is no
  `~/.config/secrets.env` — never advise adding one.
- **Host-conditional home-manager:** `home.shellAliases` is a `lib.mkMerge` of a common block plus
  `lib.mkIf` blocks keyed on `osConfig.networking.hostName`. Add host-specific user config there.

## Local LLMs (NIXCORE)

`ollama.nix` runs Ollama with CUDA on `127.0.0.1:11434`, consumed by the `pi` coding agent
(`~/.pi/agent/models.json`). Two settings there are not defaults and matter:

- `OLLAMA_CONTEXT_LENGTH` — Ollama otherwise serves **4096 tokens** regardless of what a model
  advertises, which is useless for agentic work. Not visible in `ollama show`; only the CONTEXT
  column of `ollama ps` reveals it.
- `OLLAMA_KV_CACHE_TYPE` — kept at `q4_0`. `q8_0` was measured and rejected: on a 10 GB card it
  pushes the 14B off the GPU at every useful context (29.9 tok/s vs 75.0 tok/s fully resident).

pi is declared here rather than in `dev.nix` so it does not follow SHELL, which runs no local models.

pi's own config (`~/.pi/agent/`) is **not** managed by the flake, so it does not sync between hosts:
- `models.json` — the `ollama` provider and the two context-tuned model tags
- `settings.json` — `defaultProvider`/`defaultModel`
- `auth.json` — Anthropic and DeepSeek keys, read with pi's `!command` form
  (`"key": "!cat /run/secrets/anthropic_key"`). This reads the sops secret directly rather than
  using `$ANTHROPIC_KEY`, because `home.nix` exports that variable only in *interactive* zsh — with
  the env-var form, `pi auth check` reports `not_ready` in any script or non-interactive shell.

See the `ollama-model` skill before adding a model.

## Gotchas

- **Never set `KWIN_DRM_NO_AMS`** — it blanks the display on NVIDIA.
- **The fingerprint reader needs the pinned `cv3plus` driver** in `modules/pkgs/`. The nixpkgs
  `libfprint-tod` downgrades the ControlVault firmware and bricks the chip.
- **NIXCORE has CPU boost disabled** as a stopgap from the 2026 freeze investigation (root cause was
  RAM, replaced 2026-09-03). Anything that falls back to CPU compute there is unusually slow.
