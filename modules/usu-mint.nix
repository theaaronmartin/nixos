# modules/usu-mint.nix — the secret broker's machine side (SHELL only; USU-1649).
# Spec: web-automation-v2 docs/specs/2026-09-21-secret-broker-design.md §4 (pieces, launcher,
# sudoers, pam_u2f). Imported from hosts/SHELL/default.nix as ../../modules/usu-mint.nix.
# Validate: nixos-rebuild dry-build --flake ~/nixos#SHELL   Apply: nix-switch (or
# sudo nixos-rebuild test --flake ~/nixos#SHELL first — activates without a boot entry).
#
# Deviations from the spec sketch, both deliberate:
#   * pam_u2f is scoped to the broker's OWN PAM service (`usu-mint`, selected per command by the
#     sudoers `pam_service` Default), NOT security.pam.services.sudo.u2fAuth and NOT
#     security.pam.u2f.enable. PAM policy is per service, never per command: the first put the
#     key on EVERY sudo on the machine (5d49932..b0dd375, 2026-09-21 → 22: a plain `sudo` with
#     the key unplugged failed even with the right password); the second on 25.11 defaults
#     u2fAuth ON for every PAM service (login, screen lock, display manager).
#   * COREPACK_ENABLE_DOWNLOAD_PROMPT=0 so corepack's first-run download of pnpm 11.5.0 does not
#     stop on a confirmation prompt when a terminal is present.
#
# One launcher per Auth0 tenant (USU-1694, 2026-09-24): `tenants` below. dev keeps the bare
# names (`usu-mint-token`, `usu-mint-token-real`) and byte-identical scripts, so its store
# paths, sudoers rules and every runbook line stay as they were; any other tenant gets a
# suffix (`usu-mint-token-test` → secrets/auth0-test.json). All launchers share the broker
# user, the pinned clone and the key-gated `usu-mint` PAM service; each has its own secrets
# file and its own sudoers rules. Blast radius of adding a tenant: that command's verbs only —
# plain sudo, login and screen unlock never see it.
{ config, pkgs, lib, ... }:
let
  brokerUser = "usu-mint";
  brokerHome = "/var/lib/usu-mint";
  caller = "plague";
  pamService = "usu-mint"; # /etc/pam.d/usu-mint — the broker's verbs authenticate here, plain sudo does not
  # This channel's pkgs.pnpm is 10.x and the repo is engine-strict on pnpm@11.5.0 (packageManager).
  pnpm = "corepack pnpm@11.5.0";

  tenants = [ "dev" "test" ];
  launcherName = tenant: if tenant == "dev" then "usu-mint-token" else "usu-mint-token-${tenant}";
  usageFor = tenant: "usage: ${launcherName tenant} mint [--web rd] | config | seed [args] | update <sha> | export-ci-secret | set <dotted.path>";

  # The real launcher (spec §4.2): runs as usu-mint, dispatches on $1 only, never prints a secret.
  mkReal = tenant: pkgs.writeShellApplication {
    name = "${launcherName tenant}-real";
    runtimeInputs = with pkgs; [ nodejs_24 corepack git openssh coreutils gnugrep ];
    text = ''
      export HOME=${brokerHome}
      export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
      REPO="$HOME/web-automation-v2"; SECRETS="$HOME/secrets/auth0-${tenant}.json"
      export ACC_AUTH0_CONFIG="$SECRETS"; umask 077
      verb="''${1:-}"; shift || true
      case "$verb" in
        mint)   cd "$REPO"; exec ${pnpm} exec tsx scripts/broker-mint.ts "$@" ;;
        config) cd "$REPO"; exec ${pnpm} exec tsx scripts/broker-config.ts ;;
        seed)   cd "$REPO"; exec ${pnpm} exec tsx scripts/seed-auth0-personas.ts "$@" ;;
        update) sha="''${1:?usage: update <sha>}"; cd "$REPO"
                git fetch -q origin main
                git merge-base --is-ancestor "$sha" origin/main || { echo "refusing: $sha is not on origin/main" >&2; exit 65; }
                echo "pin $(git rev-parse --short HEAD) -> $sha"; git log --oneline "HEAD..$sha" | head -50
                # The caller's CodeArtifact auth line arrives on stdin (spec §4.3); umask 077 makes it 0600.
                cat > "$HOME/.npmrc"
                git checkout -q --detach "$sha"; ${pnpm} install --frozen-lockfile ;;
        export-ci-secret) exec cat "$SECRETS" ;;
        set)    path="''${1:?usage: set <dotted.path>}"; [ -t 0 ] || { echo "set needs a terminal" >&2; exit 66; }
                cd "$REPO"; exec ${pnpm} exec tsx scripts/broker-set.ts "$path" ;;
        *) echo "${usageFor tenant}" >&2; exit 64 ;;
      esac
    '';
  };
  reals = lib.genAttrs tenants mkReal;
  realPath = tenant: "${reals.${tenant}}/bin/${launcherName tenant}-real";

  # The user-facing wrapper: sudo to usu-mint. mint/config use -n (no prompt; fails fast without
  # a rule); the privileged verbs run `sudo -k` first so no cached authentication is ever reused.
  mkBroker = tenant: pkgs.writeShellApplication {
    name = launcherName tenant;
    runtimeInputs = with pkgs; [ coreutils gnugrep ];
    text = ''
      SUDO=/run/wrappers/bin/sudo      # the setuid wrapper — never a sudo from PATH
      REAL=${realPath tenant}
      verb="''${1:-}"; shift || true
      case "$verb" in
        mint|config)
          exec "$SUDO" -n -u ${brokerUser} "$REAL" "$verb" "$@" ;;
        seed|export-ci-secret|set)
          "$SUDO" -k
          exec "$SUDO" -u ${brokerUser} "$REAL" "$verb" "$@" ;;
        update)
          sha="''${1:?usage: ${launcherName tenant} update <sha>}"
          # The caller's 12-hour, read-only CodeArtifact line rides stdin into the boundary
          # (spec §4.3): less-trusted -> more-trusted, never argv.
          line="$(grep -E '^//.*codeartifact.*:_authToken=' "$HOME/.npmrc" || true)"
          [ -n "$line" ] || { echo "no CodeArtifact auth line in $HOME/.npmrc — run the service repo's scripts/codeartifact-login.sh first" >&2; exit 64; }
          "$SUDO" -k
          printf '%s\n' "$line" | "$SUDO" -u ${brokerUser} "$REAL" update "$sha" ;;
        *) echo "${usageFor tenant}" >&2; exit 64 ;;
      esac
    '';
  };

  nopass = tenant: c: { command = "${realPath tenant} ${c}"; options = [ "NOPASSWD" ]; };
  pass = tenant: c: { command = "${realPath tenant} ${c}"; options = [ "PASSWD" ]; };
  # sudoers (spec §4.1): bare and `*` forms both listed — sudoers matches a bare command only with
  # no arguments. No timestamp cache for the privileged verbs.
  rulesFor = tenant: [
    (nopass tenant "mint")
    (nopass tenant "mint *")
    (nopass tenant "config")
    (pass tenant "seed")
    (pass tenant "seed *")
    (pass tenant "update *")
    (pass tenant "export-ci-secret")
    (pass tenant "set *")
  ];
in
{
  users.groups.${brokerUser} = { };
  users.users.${brokerUser} = {
    isSystemUser = true;
    group = brokerUser;
    home = brokerHome;
    createHome = true;
    homeMode = "0750";
    shell = "${pkgs.shadow}/bin/nologin";
  };
  systemd.tmpfiles.rules = [
    "d ${brokerHome}/secrets 0700 ${brokerUser} ${brokerUser} -"
    "d ${brokerHome}/.ssh 0700 ${brokerUser} ${brokerUser} -"
  ];

  environment.systemPackages = (map mkBroker tenants) ++ [ pkgs.pam_u2f ];

  security.sudo.extraRules = [
    {
      users = [ caller ];
      runAs = brokerUser;
      commands = lib.concatMap rulesFor tenants;
    }
  ];
  # pam_service is a per-command Default: sudo applies Defaults! in set_cmnd() before check_user()
  # runs PAM (sudo 1.9.17p2 plugins/sudoers/sudoers.c:369, auth/pam.c:224).
  security.sudo.extraConfig = lib.concatMapStrings (tenant: ''
    Defaults!${realPath tenant} timestamp_timeout=0
    Defaults!${realPath tenant} pam_service="${pamService}"
  '') tenants;

  # pam_u2f on the broker's PAM service ONLY — password AND touch ("required"; rolled out
  # "sufficient" → "required" per spec §4.1, §4.4 step 6). The `sudo` service keeps the host
  # default (fingerprint OR password), so everyday sudo never sees the key.
  security.pam.u2f = {
    enable = false; # keep the global default off: see the header comment
    control = "required";
    settings = {
      cue = true;
      authfile = "/etc/u2f_mappings"; # root-owned; a mapping under $HOME could be replaced by the agent
      origin = "pam://SHELL";
      appid = "pam://SHELL";
    };
  };
  security.pam.services.${pamService} = {
    u2fAuth = true;
    # fprintAuth defaults to services.fprintd.enable (on, this laptop); off here, or a touch plus a
    # fingerprint would satisfy the stack without the password.
    fprintAuth = false;
  };
}
