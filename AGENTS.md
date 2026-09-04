# AGENTS.md

Behavioural guidance for agents working in this repository.

**Facts about this repo live in `CLAUDE.md`** — commands, host layout, the module table, secrets
handling, and known gotchas. Read it first. This file intentionally does not restate any of it:
the two files used to carry duplicate architecture sections, drifted apart, and by 2026-09 this one
was describing a single-host config at `~/nixos-config` that had not existed for months. Do not
reintroduce that duplication. If a fact belongs anywhere, it belongs in `CLAUDE.md`.

## Executive Autonomy

- You are expected to solve problems, not report them.
- If a file path is unknown, use `find` or `glob`.
- If a group ID is mentioned, find its definition in `users.nix` or `security.nix` before proceeding.
- **NEVER** ask the user to provide output from a command you have the power to run yourself.
- The one exception is `sudo`: `plague` has no passwordless sudo, so `nixos-rebuild switch` must be
  handed to the user. Validate with `nixos-rebuild dry-build` (no sudo needed) first.

## Tool-Calling & Exploration Protocol

- **State verification:** before proposing any change, verify file existence and current imports
  with `ls` / `grep`. Both host `default.nix` files import different module sets — check which host
  you are affecting.
- **Read first:** if a module in `modules/` is mentioned, read it entirely before commenting. Many
  carry header comments explaining why they were split apart; those comments are authoritative.
- **No permission needed:** you have full authority to read, list, and grep the repository. Do not
  ask.
- **Context preservation:** when refactoring a module, check `flake.nix` and both
  `hosts/*/default.nix` first to see how it is imported and what is passed via `specialArgs`.

## Hardware & Service Troubleshooting

- **Logs first:** `journalctl -u <service> -n 50 --no-pager`.
- **Verify, don't assume:** after a rebuild, confirm the change actually landed —
  `systemctl show <unit> -p Environment`, `systemctl is-active`, or the service's own status
  output. A successful `switch` does not prove a unit picked up what you intended.
- **Measure GPU work:** NIXCORE has an RTX 3080 with 10 GB, which is the binding constraint for
  local models and transcoding. `nvidia-smi` for allocation, `ollama ps` for model placement —
  a model reported as loaded may be silently running partly on CPU.
- **Nix-specific debugging:** use `nix-shell -p <package>` to test a tool before suggesting its
  permanent addition.

## Strict Workflow Constraints

- **Do NOT** convert Neovim or WezTerm dotfiles to `home.file` copies. They must stay
  `mkOutOfStoreSymlink` to preserve the live-edit workflow.
- **Do NOT** hardcode secrets, and **do not** suggest `~/.config/secrets.env` — secrets are
  sops-nix, read from `/run/secrets/`. See `CLAUDE.md`.
- **Formatting:** adhere to `nixpkgs-fmt` for all `.nix` code.
- **Host scope:** before adding a module to a host, confirm it belongs there. Several modules exist
  precisely because desktop-only policy was leaking onto the laptop.

## Preferred Execution

- After changing the flake, suggest `nix-switch` rather than the full `nixos-rebuild` command — it
  is host-conditional and resolves to the correct target on either machine.
