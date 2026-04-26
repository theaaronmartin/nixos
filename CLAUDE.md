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

This is a multi-host NixOS flake config for two machines (both x86_64-linux):
- **NIXCORE** — desktop (AMD CPU, NVIDIA GPU)
- **SHELL** — laptop/WSL (Intel CPU, Intel Arc GPU)

**Flake inputs:**
- `nixpkgs` → `nixos-25.11` (stable) — used for most system packages
- `nixpkgs-unstable` — exposed as `pkgs-unstable`, passed via `specialArgs` for packages that need newer versions
- `home-manager` → `release-25.11` — manages user-level config for the `plague` user
- `nix-citizen` — provides the Star Citizen runner

**Entry points:**
- `flake.nix` — defines inputs and both `nixosConfigurations.NIXCORE` and `nixosConfigurations.SHELL` outputs
- `hosts/NIXCORE/default.nix` — NIXCORE-specific config: kernel params, NVIDIA setup, hardware overrides; imports shared modules
- `hosts/SHELL/default.nix` — SHELL-specific config: WSL setup, Intel GPU, networking overrides; imports shared modules
- `home.nix` — shared home-manager config for user `plague` on both hosts: shell aliases, dotfile symlinks via `mkOutOfStoreSymlink`, and user packages

**Shared modules** (`modules/`):

| File | Purpose |
|------|---------|
| `audio.nix` | PipeWire (JACK + ALSA + PulseAudio), low-latency tuning, DecentSampler derivation, NI zone FHS env, PAM real-time limits |
| `base.nix` | Common system packages (parted, wget, etc.) shared across all hosts |
| `boot.nix` | systemd-boot config |
| `desktop.nix` | KDE Plasma 6 + SDDM, Firefox, Vesktop autostart systemd unit |
| `dev.nix` | Developer tools (ripgrep, fd, etc.) available system-wide |
| `games.nix` | Steam, GameMode, Lutris, ProtonUp, Starsector FHS wrapper |
| `hardware.nix` | Hardware enablement shared across hosts |
| `hm-dev.nix` | Home-manager dev environment: WezTerm, Neovim |
| `locale.nix` | Timezone (`America/Los_Angeles`) and locale settings |
| `media.nix` | Jellyfin (NVIDIA HW accel override), Radarr, Sonarr, SABnzbd, Navidrome — all in the `media` group (GID 989) |
| `network.nix` | NetworkManager, Docker, Nginx Proxy Manager OCI container, firewall rules |
| `ollama.nix` | Ollama LLM service (currently commented out) |
| `openrgb.nix` | OpenRGB service, ee1004 unbind workaround, boot color systemd oneshot |
| `security.nix` | YubiKey (yubioath, pcscd, udev rules) |
| `star-citizen.nix` | Star Citizen runner from nix-citizen flake, sysctl tuning |
| `storage.nix` | Mounts for `/mnt/media_01`, `/mnt/media_02`, `/mnt/games`; MergerFS pool at `/mnt/media` |
| `users.nix` | `plague` user definition, group memberships, user packages, SSH agent |
| `work.nix` | Work-related packages (teams-for-linux, etc.) — imported by SHELL |

**Dotfiles** (`dotfiles/`): Neovim and WezTerm configs are symlinked (not copied) into `~/.config` using `mkOutOfStoreSymlink`, so edits take effect immediately without rebuilding. Starship config is read at build time via `builtins.readFile`.

## Important Patterns

- **Two package sets:** Use `pkgs` for stable packages, `pkgs-unstable` (passed via `specialArgs`/`extraSpecialArgs`) for anything needing a newer version.
- **Media group:** All media services (Jellyfin, Radarr, Sonarr, SABnzbd, Navidrome) share GID 989 (`media`). When adding new media services, add them to `users.groups.media.members` in `media.nix`.
- **Jellyfin NVIDIA HW accel:** The `systemd.services.jellyfin.serviceConfig` overrides in `media.nix` are required for GPU transcoding — NixOS's default Jellyfin service locks down device access.
- **OpenRGB boot sequence:** The ee1004 unbind must run before OpenRGB starts, and color-setting runs after with a 5s delay. This ordering is enforced via `before`/`after` in the systemd unit definitions.
- **`lib.mkForce`:** Used throughout `media.nix` to override default systemd service hardening that would block media paths.
- **Secrets:** Loaded at runtime from `~/.config/secrets.env` (sourced in `.bashrc`) and `/var/lib/navidrome/navidrome.env`. Never hardcoded in the flake.
