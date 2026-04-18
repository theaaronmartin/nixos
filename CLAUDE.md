# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Key Commands

```bash
# Apply config changes to the running system
sudo nixos-rebuild switch --flake ~/nixos#{NIXCORE/SHELL}

# Shorthand alias (defined in home.nix)
nixcore-switch
shell-switch

# Garbage collect old generations
sudo nix-collect-garbage -d   # alias: nix-clean

# Check flake for errors without building
nix flake check

# Build without switching (useful for checking errors)
sudo nixos-rebuild build --flake ~/nixos#{NIXCORE/SHELL}
```

## Architecture

This is a single-host NixOS flake config for the machines `NIXCORE` & `SHELL` (x86_64-linux).

**Flake inputs:**
- `nixpkgs` → `nixos-25.11` (stable) — used for most system packages
- `nixpkgs-unstable` — exposed as `pkgs-unstable`, passed via `specialArgs` for packages that need newer versions
- `home-manager` → `release-25.11` — manages user-level config for the `plague` user
- `nix-citizen` — provides the Star Citizen runner

**Entry points:**
- `flake.nix` — defines inputs and the single `nixosConfigurations.NIXCORE` output
- `configuration.nix` — imports all system modules; minimal itself
- `home.nix` — home-manager config for user `plague`: shell aliases, dotfile symlinks via `mkOutOfStoreSymlink`, and user packages (LSPs, dev tools)

**System modules** (`modules/`):

| File | Purpose |
|------|---------|
| `audio.nix` | PipeWire (JACK + ALSA + PulseAudio), low-latency tuning, DecentSampler derivation, NI zone FHS env, PAM real-time limits |
| `boot.nix` | systemd-boot, zen kernel, AMD CPU tuning, NVIDIA kernel params |
| `desktop.nix` | KDE Plasma 6 + SDDM, Firefox, Vesktop autostart systemd unit |
| `games.nix` | Steam, GameMode, Lutris, ProtonUp, Starsector FHS wrapper |
| `hardware.nix` | AMD microcode, NVIDIA drivers (proprietary), nvidia-container-toolkit, i2c, performance governor |
| `media.nix` | Jellyfin (NVIDIA HW accel override), Radarr, Sonarr, SABnzbd, Navidrome — all in the `media` group (GID 989) |
| `network.nix` | NetworkManager, Docker, Nginx Proxy Manager OCI container, firewall rules |
| `openrgb.nix` | OpenRGB service, ee1004 unbind workaround, boot color systemd oneshot |
| `security.nix` | YubiKey (yubioath, pcscd, udev rules) |
| `star-citizen.nix` | Star Citizen runner from nix-citizen flake, sysctl tuning |
| `storage.nix` | Mounts for `/mnt/media_01`, `/mnt/media_02`, `/mnt/games`; MergerFS pool at `/mnt/media` |
| `users.nix` | `plague` user definition, group memberships, user packages, SSH agent |

**Dotfiles** (`dotfiles/`): Neovim and WezTerm configs are symlinked (not copied) into `~/.config` using `mkOutOfStoreSymlink`, so edits take effect immediately without rebuilding. Starship config is read at build time via `builtins.readFile`.

## Important Patterns

- **Two package sets:** Use `pkgs` for stable packages, `pkgs-unstable` (passed via `specialArgs`/`extraSpecialArgs`) for anything needing a newer version.
- **Media group:** All media services (Jellyfin, Radarr, Sonarr, SABnzbd, Navidrome) share GID 989 (`media`). When adding new media services, add them to `users.groups.media.members` in `media.nix`.
- **Jellyfin NVIDIA HW accel:** The `systemd.services.jellyfin.serviceConfig` overrides in `media.nix` are required for GPU transcoding — NixOS's default Jellyfin service locks down device access.
- **OpenRGB boot sequence:** The ee1004 unbind must run before OpenRGB starts, and color-setting runs after with a 5s delay. This ordering is enforced via `before`/`after` in the systemd unit definitions.
- **`lib.mkForce`:** Used throughout `media.nix` to override default systemd service hardening that would block media paths.
- **Secrets:** Loaded at runtime from `~/.config/secrets.env` (sourced in `.bashrc`) and `/var/lib/navidrome/navidrome.env`. Never hardcoded in the flake.
