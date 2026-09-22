# modules/usu-mint.nix — the secret broker's machine side (SHELL only; USU-1649).
# Spec: web-automation-v2 docs/specs/2026-09-21-secret-broker-design.md §4 (pieces, launcher,
# sudoers, pam_u2f). Imported from hosts/SHELL/default.nix as ../../modules/usu-mint.nix.
# Validate: nixos-rebuild dry-build --flake ~/nixos#SHELL   Apply: nix-switch (or
# sudo nixos-rebuild test --flake ~/nixos#SHELL first — activates without a boot entry).
#
# Deviations from the spec sketch, both deliberate:
#   * pam_u2f is scoped to the sudo service only (security.pam.services.sudo.u2fAuth), NOT
#     security.pam.u2f.enable — on 25.11 the global switch defaults u2fAuth ON for EVERY PAM
#     service (login, screen lock, display manager), which with control = "sufficient" would
#     make a touch alone unlock the machine and with "required" would lock every login to the key.
#   * COREPACK_ENABLE_DOWNLOAD_PROMPT=0 so corepack's first-run download of pnpm 11.5.0 does not
#     stop on a confirmation prompt when a terminal is present.
{ config, pkgs, lib, ... }:
let
  brokerUser = "usu-mint";
  brokerHome = "/var/lib/usu-mint";
  caller = "plague";
  # This channel's pkgs.pnpm is 10.x and the repo is engine-strict on pnpm@11.5.0 (packageManager).
  pnpm = "corepack pnpm@11.5.0";
  usage = "usage: usu-mint-token mint [--web rd] | config | seed [args] | update <sha> | export-ci-secret | set <dotted.path>";

  # The real launcher (spec §4.2): runs as usu-mint, dispatches on $1 only, never prints a secret.
  brokerReal = pkgs.writeShellApplication {
    name = "usu-mint-token-real";
    runtimeInputs = with pkgs; [ nodejs_24 corepack git openssh coreutils gnugrep ];
    text = ''
      export HOME=${brokerHome}
      export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
      REPO="$HOME/web-automation-v2"; SECRETS="$HOME/secrets/auth0-dev.json"
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
        *) echo "${usage}" >&2; exit 64 ;;
      esac
    '';
  };

  # The user-facing wrapper: sudo to usu-mint. mint/config use -n (no prompt; fails fast without
  # a rule); the privileged verbs run `sudo -k` first so no cached authentication is ever reused.
  broker = pkgs.writeShellApplication {
    name = "usu-mint-token";
    runtimeInputs = with pkgs; [ coreutils gnugrep ];
    text = ''
      SUDO=/run/wrappers/bin/sudo      # the setuid wrapper — never a sudo from PATH
      REAL=${brokerReal}/bin/usu-mint-token-real
      verb="''${1:-}"; shift || true
      case "$verb" in
        mint|config)
          exec "$SUDO" -n -u ${brokerUser} "$REAL" "$verb" "$@" ;;
        seed|export-ci-secret|set)
          "$SUDO" -k
          exec "$SUDO" -u ${brokerUser} "$REAL" "$verb" "$@" ;;
        update)
          sha="''${1:?usage: usu-mint-token update <sha>}"
          # The caller's 12-hour, read-only CodeArtifact line rides stdin into the boundary
          # (spec §4.3): less-trusted -> more-trusted, never argv.
          line="$(grep -E '^//.*codeartifact.*:_authToken=' "$HOME/.npmrc" || true)"
          [ -n "$line" ] || { echo "no CodeArtifact auth line in $HOME/.npmrc — run the service repo's scripts/codeartifact-login.sh first" >&2; exit 64; }
          "$SUDO" -k
          printf '%s\n' "$line" | "$SUDO" -u ${brokerUser} "$REAL" update "$sha" ;;
        *) echo "${usage}" >&2; exit 64 ;;
      esac
    '';
  };
  real = "${brokerReal}/bin/usu-mint-token-real";
  nopass = c: { command = "${real} ${c}"; options = [ "NOPASSWD" ]; };
  pass = c: { command = "${real} ${c}"; options = [ "PASSWD" ]; };
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

  environment.systemPackages = [ broker pkgs.pam_u2f ];

  # sudoers (spec §4.1): bare and `*` forms both listed — sudoers matches a bare command only with
  # no arguments. No timestamp cache for the privileged verbs.
  security.sudo.extraRules = [
    {
      users = [ caller ];
      runAs = brokerUser;
      commands = [
        (nopass "mint")
        (nopass "mint *")
        (nopass "config")
        (pass "seed")
        (pass "seed *")
        (pass "update *")
        (pass "export-ci-secret")
        (pass "set *")
      ];
    }
  ];
  security.sudo.extraConfig = ''
    Defaults!${real} timestamp_timeout=0
  '';

  # pam_u2f on sudo ONLY. Roll out with "sufficient" (touch OR password) to verify, then flip to
  # "required" (password AND touch) — spec §4.1, §4.4 step 6.
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
  security.pam.services.sudo.u2fAuth = true;
}
