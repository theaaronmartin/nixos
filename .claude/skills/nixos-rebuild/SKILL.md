---
name: nixos-rebuild
description: Apply and verify a NixOS config change on NIXCORE or SHELL. Use after editing anything in this flake, when a rebuild fails to evaluate, when a change appears not to have taken effect, or when a switch needs rolling back. Triggers on "rebuild", "switch", "nix-switch", "dry-build", "rollback", "generation".
---

# Rebuild and verify

`CLAUDE.md` lists the commands. This skill is about the half that gets skipped: proving the change
landed, and not burning a switch to find out it did not.

## 1. Evaluate first — free, and needs no sudo

```bash
nixos-rebuild dry-build --flake ~/nixos#NIXCORE   # or #SHELL
```

This catches eval errors, bad option names, and type mismatches without building or activating
anything. It also prints what *would* be built, which tells you the blast radius. A change touching
one systemd unit should show a handful of derivations:

```
these 4 derivations will be built:
  .../unit-ollama.service.drv
  .../system-units.drv
  .../etc.drv
  .../nixos-system-NIXCORE-....drv
```

If it wants to build hundreds, something pulled in a package-set change — understand why before
switching.

Confirm the host too. `dry-build` against the wrong host succeeds and tells you nothing:

```bash
hostname
```

## 2. Hand the switch to the user

**`plague` has no passwordless sudo.** An agent cannot run this, over SSH or locally. Do not try and
report failure — give the user the command:

```
! ssh -t plague@192.168.0.198 'sudo nixos-rebuild switch --flake /home/plague/nixos#NIXCORE'
```

Locally on either machine, `nix-switch` is the alias — host-conditional, resolves to the right
target. There is no `nixcore-switch` or `shell-switch`.

## 3. Verify the change actually took effect

A successful `switch` proves the system built and activated. It does **not** prove the unit you
cared about picked up what you intended. Check the specific thing you changed:

```bash
# environment variables on a service
systemctl show <unit> -p Environment | tr ' ' '\n'

# is it running, and did it restart?
systemctl is-active <unit>
systemctl show <unit> -p ActiveEnterTimestamp

# the generated unit, which is what is really in effect
systemctl cat <unit>

# did activation complain?
journalctl -u <unit> -n 30 --no-pager
```

Then verify the *behaviour*, not just the config. Config and effect diverge in ways only a
measurement catches — on 2026-09-04 an Ollama KV-cache change applied exactly as written and
silently pushed a model off the GPU, which no amount of reading `systemctl show` would have
revealed. If the change was meant to affect performance, placement, or capacity, measure it.

## 4. Rolling back

```bash
sudo nixos-rebuild switch --rollback     # previous generation
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

Old generations also remain in the systemd-boot menu, which is the escape hatch if a change breaks
the display or boot. Note that `nix-collect-garbage -d` (alias `nix-clean`) **deletes those
generations** — do not run it immediately after a risky change.

## 5. Repo hygiene

- Both hosts clone the same repo (`origin` = `github.com/theaaronmartin/nixos`), so a change is not
  on the other machine until pushed and pulled. Check `git status` before assuming the config on
  disk is what is deployed.
- A dirty tree is fine to build from — `nixos-rebuild` warns "Git tree is dirty" and proceeds — but
  the generation will not correspond to any commit.
- Format `.nix` changes with `nixpkgs-fmt`.
- Confirm which host imports the module you edited. `hosts/NIXCORE/default.nix` and
  `hosts/SHELL/default.nix` import different sets; editing a shared module affects both.

## Known traps

- **Never set `KWIN_DRM_NO_AMS`** — blanks the display on NVIDIA. If a switch leaves a black screen,
  boot the previous generation.
- **Never reintroduce `wsl.nix` on SHELL.** It force-disables NetworkManager and the firewall, and
  SHELL has been bare metal since 2026-09-01.
- **The age keyfile must exist before the first rebuild on a fresh machine**
  (`~/.config/sops/age/keys.txt`). `home.nix` unconditionally reads `/run/secrets/*` in zsh init, so
  without it activation fails and every new shell throws.
- **Never suggest `~/.config/secrets.env`.** Secrets are sops-nix. See `CLAUDE.md`.
