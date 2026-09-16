# Native Instruments (Native Access + Kontakt) on NIXCORE.
#
# NIXCORE-only: SHELL has no NI setup. Imported from hosts/NIXCORE.
#
# ---------------------------------------------------------------------------
# Why this module is shaped the way it is
# ---------------------------------------------------------------------------
# Two wines, and they must not be mixed:
#
#   naWine (11.15)  Native Access 2 is Electron and calls a UAC API wine only
#                   learned in 11.4, so 25.11's 10.20 cannot install it.
#   ybWine (9.21)   yabridge does not work on wine 10+. Upstream says so
#                   outright and nixpkgs pins it to 9.21. On 11.15 plugins
#                   build, sync and load, but every plugin editor renders and
#                   then silently ignores all mouse input - confirmed on both
#                   Kontakt and FabFilter.
#
# Kontakt also cannot run outside the prefix Native Access set up. Mirroring
# NI registry keys into a separate prefix does not work, nor does copying
# Kontakt's komplete.db3 rows, nor re-running the installer there - all three
# were tried and Kontakt stayed in demo mode with no libraries. NA writes far
# more prefix-local state than can be replicated piecemeal. So the plugin side
# gets a straight copy of the whole prefix instead.
#
# The prefixes themselves are mutable runtime state and cannot live in the nix
# store. What is declarative here is everything needed to rebuild them:
# the powershell shim, the helper scripts, and ni-bootstrap-prefix.
#
#   ~/.wine-ni          naWine   Native Access (authoritative)
#   ~/.wine-ni-plugins  ybWine   copy of the above; what yabridge loads
#   ~/.wine-plugins     ybWine   third-party Windows plugins
#   ~/.wine-vst         ybWine   FabFilter (win32, predates this module)
{ pkgs, pkgs-unstable, ... }:
let
  naWine = pkgs-unstable.wineWowPackages.stagingFull;

  # The exact wine nixpkgs builds yabridge against. Referenced directly rather
  # than parsed out of the yabridge-host wrapper at runtime, so it cannot drift.
  ybWine = pkgs.wineWowPackages.yabridge;

  shim = pkgs.callPackage ./pkgs/ni-powershell-shim/package.nix { };

  niPrefix = "$HOME/.wine-ni";
  pluginCopy = "$HOME/.wine-ni-plugins";
  thirdParty = "$HOME/.wine-plugins";

  # Every script needs a display and must avoid wine's Wayland backend, which
  # is the less-tested path for Electron.
  wineEnv = ''
    export DISPLAY="''${DISPLAY:-:0}"
    if [ -z "''${XAUTHORITY:-}" ]; then
      for x in /run/user/"$(id -u)"/xauth_*; do
        [ -e "$x" ] && export XAUTHORITY="$x" && break
      done
    fi
    unset WAYLAND_DISPLAY
  '';

  ni-access = pkgs.writeShellApplication {
    name = "ni-access";
    runtimeInputs = [ naWine pkgs.iproute2 pkgs.procps ];
    text = ''
      # Launch Native Access.
      #
      #  NTKDaemon must be started AS A SERVICE and waited for. Run as a bare
      #  exe it logs "Running Daemon as an Service", hands off to the SCM and
      #  exits without ever binding. Native Access then fails its ZMQ version
      #  probe, falls back to `wmic` (which wine answers with "Alias not
      #  found"), concludes the daemon is missing, tries to reinstall it, hits
      #  UAC and dies on "Please grant permission to Native Access to install
      #  dependencies". A fixed sleep is not enough; it takes ~10-20s to bind.
      #
      #  --disable-gpu because Electron cannot init EGL against the NVIDIA card
      #  through wine; without it you get a window with a menu bar and no
      #  content.
      #
      #  setsid + </dev/null + a real log file because Electron creates
      #  process.stderr lazily. If it inherited a pipe whose far end has closed
      #  (say, a finished ssh command) the first write throws "Error: open
      #  EBADF" and Electron reports "A JavaScript error occurred in the main
      #  process" - which looks like a login failure and is not.
      export WINEPREFIX="${niPrefix}"
      export WINEARCH=win64
      ${wineEnv}

      LOG="''${NI_LOG:-$HOME/.cache/ni-access.log}"
      mkdir -p "$(dirname "$LOG")"

      NA="$WINEPREFIX/drive_c/Program Files/Native Instruments/Native Access"
      if [ ! -d "$NA" ]; then
        echo "!! Native Access is not installed in $WINEPREFIX" >&2
        echo "   run: ni-bootstrap-prefix" >&2
        exit 1
      fi

      daemon_listening() {
        ss -lnt 2>/dev/null | grep -qE '127\.0\.0\.1:(5146|5563)\b'
      }

      if ! daemon_listening; then
        echo ">> starting NTKDaemonService" >&2
        wine net start NTKDaemonService >>"$LOG" 2>&1 || true
        for _ in $(seq 1 60); do
          daemon_listening && break
          sleep 1
        done
      fi

      if daemon_listening; then
        echo ">> NTKDaemon listening" >&2
      else
        echo "!! NTKDaemon never bound 5146/5563 - Native Access will hit the" >&2
        echo "   'grant permission to install dependencies' wall. See $LOG" >&2
      fi

      echo ">> launching Native Access (log: $LOG)" >&2
      cd "$NA"
      setsid wine "Native Access.exe" \
        --disable-gpu --no-sandbox --disable-software-rasterizer "$@" \
        </dev/null >>"$LOG" 2>&1 &
    '';
  };

  ni-refresh-plugins = pkgs.writeShellApplication {
    name = "ni-refresh-plugins";
    runtimeInputs = [ pkgs.rsync pkgs.yabridgectl pkgs.procps ];
    text = ''
      # Refresh the plugin-side copy of the Native Access prefix.
      #
      # RUN THIS AFTER INSTALLING ANYTHING IN NATIVE ACCESS, then rescan in
      # your DAW. Native Access writes into ${niPrefix}; yabridge loads from
      # the copy, so the copy has to be brought forward.
      #
      # The library content is symlinked rather than duplicated, so the copy
      # costs roughly half what the original does.
      SRC="${niPrefix}"
      DST="${pluginCopy}"
      CONTENT_REL="drive_c/users/Public/Documents"

      [ -d "$SRC" ] || { echo "!! $SRC missing - run ni-bootstrap-prefix" >&2; exit 1; }

      if pgrep -f yabridge-host >/dev/null 2>&1; then
        echo "!! a bridged plugin is loaded (yabridge-host is running)." >&2
        echo "   Close it in your DAW first or the copy may be inconsistent." >&2
        exit 1
      fi

      echo ">> refreshing $DST from $SRC"
      rsync -a --delete --exclude "$CONTENT_REL/" "$SRC/" "$DST/"

      mkdir -p "$DST/drive_c/users/Public"
      ln -sfn "$SRC/$CONTENT_REL" "$DST/$CONTENT_REL"

      echo ">> yabridgectl sync"
      yabridgectl sync 2>&1 | tail -2

      echo ">> done. Rescan plugins in your DAW if something new was installed."
    '';
  };

  install-win-plugin = pkgs.writeShellApplication {
    name = "install-win-plugin";
    runtimeInputs = [ ybWine pkgs.yabridgectl pkgs.unzip pkgs.procps pkgs.findutils ];
    text = ''
      # Install a Windows VST/VST3 plugin and bridge it with yabridge.
      #
      #   install-win-plugin <installer.exe|bundle.zip>
      #   install-win-plugin --sync      re-register directories and sync
      #   install-win-plugin --status    show everything yabridge bridges
      #   install-win-plugin --prefix P  use a different prefix
      #
      # Always uses yabridge's own wine, never the system one - the system wine
      # is 11.15 for Native Access, and plugin editors ignore mouse input there.
      PREFIX="${thirdParty}"
      ACTION=install
      SRC=""

      while [ $# -gt 0 ]; do
        case "$1" in
          --prefix) PREFIX="$2"; shift 2 ;;
          --sync)   ACTION=sync; shift ;;
          --status) ACTION=status; shift ;;
          -h|--help) echo "usage: install-win-plugin <installer.exe|bundle.zip> | --sync | --status"; exit 0 ;;
          *) SRC="$1"; shift ;;
        esac
      done

      # Refuse the Native Access copy: ni-refresh-plugins rsync --delete's over
      # it, so anything installed there is destroyed on the next NA refresh.
      if [ "$(readlink -f "$PREFIX")" = "$(readlink -f "${pluginCopy}" 2>/dev/null)" ]; then
        echo "!! refusing: ${pluginCopy} is rebuilt by ni-refresh-plugins" >&2
        echo "   (rsync --delete); anything installed there would be wiped." >&2
        exit 1
      fi

      export WINEPREFIX="$PREFIX"
      export WINEARCH=win64
      ${wineEnv}

      plugin_dirs() {
        printf '%s\n' \
          "$PREFIX/drive_c/Program Files/Common Files/VST3" \
          "$PREFIX/drive_c/Program Files/Common Files/CLAP" \
          "$PREFIX/drive_c/Program Files/Steinberg/VSTPlugins" \
          "$PREFIX/drive_c/Program Files/VstPlugins" \
          "$PREFIX/drive_c/Program Files/Common Files/VST2"
      }

      register_and_sync() {
        while IFS= read -r d; do
          [ -d "$d" ] || continue
          if ! find "$d" -maxdepth 2 \
               \( -iname '*.vst3' -o -iname '*.dll' -o -iname '*.clap' \) \
               -print -quit 2>/dev/null | grep -q .; then
            continue
          fi
          if yabridgectl status 2>/dev/null | grep -qF "$d"; then
            echo "   already registered: ''${d#"$PREFIX"/drive_c/}"
          else
            yabridgectl add "$d" >/dev/null 2>&1 && echo "   + ''${d#"$PREFIX"/drive_c/}"
          fi
        done < <(plugin_dirs)
        echo ">> yabridgectl sync"
        yabridgectl sync 2>&1 | tail -2
      }

      case "$ACTION" in
        status) yabridgectl status; exit 0 ;;
        sync)   echo ">> wine: $(wine --version)  prefix: $PREFIX"
                register_and_sync; exit 0 ;;
        *) ;;
      esac

      [ -n "$SRC" ] || { echo "usage: install-win-plugin <installer.exe|bundle.zip>" >&2; exit 1; }
      [ -e "$SRC" ] || { echo "!! no such file: $SRC" >&2; exit 1; }

      echo ">> wine:   $(wine --version)"
      echo ">> prefix: $PREFIX"

      if [ ! -d "$PREFIX" ]; then
        echo ">> creating prefix"
        wineboot -u >/dev/null 2>&1 || true
        wineserver -w
        wine reg add 'HKCU\Software\Wine\Drivers' /v Graphics /d x11 /f >/dev/null 2>&1 || true
        wine winecfg /v win10 >/dev/null 2>&1 || true
        wineserver -w
      fi

      EXE="$SRC"
      case "''${SRC,,}" in
        *.zip)
          WORK="$(mktemp -d /tmp/winplugin.XXXXXX)"
          echo ">> unpacking $(basename "$SRC")"
          unzip -o -q "$SRC" -d "$WORK"
          EXE="$(find "$WORK" -iname '*.exe' | head -1)"
          [ -n "$EXE" ] || { echo "!! no .exe inside the zip" >&2; exit 1; }
          ;;
      esac
      echo ">> installer: $(basename "$EXE")"

      LOG="$HOME/.cache/install-win-plugin.log"
      mkdir -p "$(dirname "$LOG")"; : > "$LOG"

      cd "$(dirname "$EXE")"
      setsid wine "$EXE" </dev/null >>"$LOG" 2>&1 &
      echo ">> installer running on $DISPLAY - click through it"

      for _ in $(seq 1 360); do
        sleep 5
        # shellcheck disable=SC2009  # deliberately NOT pgrep -f: that matches
        # this script's own command line (and an ssh wrapper's), which has
        # killed the calling session before. Match on comm only.
        n="$(ps -eo comm --no-headers | grep -ciE 'setup|install|\.exe' || true)"
        [ "''${n:-0}" -eq 0 ] && break
      done
      wineserver -w 2>/dev/null || true

      echo ">> registering plugin directories"
      register_and_sync
      echo
      echo ">> done. Re-scan VSTs in REAPER:"
      echo "   Options -> Preferences -> Plug-ins -> VST -> Re-scan"
    '';
  };

  ni-bootstrap-prefix = pkgs.writeShellApplication {
    name = "ni-bootstrap-prefix";
    runtimeInputs = [ naWine pkgs.curl pkgs.iproute2 pkgs.procps ];
    text = ''
      # Build ~/.wine-ni from nothing: wine prefix, powershell shim, Native
      # Access, NTK daemon. Run this after a wipe, then log in to NA and
      # reinstall libraries.
      #
      # Everything here was worked out the hard way; see
      # ~/NI_installers/NI-NOTES.md for the full reasoning.
      export WINEPREFIX="${niPrefix}"
      export WINEARCH=win64
      ${wineEnv}

      NA_URL="https://storage.googleapis.com/ni-assets/downloads/Native-Access_2.exe"
      DL="$HOME/NI_installers"
      LOG="$HOME/.cache/ni-bootstrap.log"
      mkdir -p "$DL" "$(dirname "$LOG")"; : > "$LOG"

      if [ -d "$WINEPREFIX" ] && [ "''${1:-}" != "--force" ]; then
        echo "!! $WINEPREFIX already exists. Pass --force to build it anyway." >&2
        exit 1
      fi

      echo ">> creating prefix"
      wineboot -u >>"$LOG" 2>&1 || true
      wineserver -w
      # Anything below win10 makes NI installers hang on their ISO driver step.
      wine winecfg /v win10 >>"$LOG" 2>&1 || true
      # wine's Wayland backend is the worse path for Electron.
      wine reg add 'HKCU\Software\Wine\Drivers' /v Graphics /d x11 /f >>"$LOG" 2>&1 || true
      wineserver -w

      # Without this the NI installer reads wine's always-0 powershell stub as
      # "Native Access is already running", aborts and rolls back.
      echo ">> installing powershell shim"
      for pair in "system32:powershell64.exe" "syswow64:powershell32.exe"; do
        d="''${pair%%:*}"; src="''${pair##*:}"
        t="$WINEPREFIX/drive_c/windows/$d/WindowsPowerShell/v1.0/powershell.exe"
        if [ -f "$t" ]; then
          [ -f "$t.wine-orig" ] || cp "$t" "$t.wine-orig"
          cp "${shim}/bin/$src" "$t"
          echo "   $d"
        fi
      done

      if [ ! -f "$DL/Native-Access_2.exe" ]; then
        echo ">> downloading Native Access"
        curl -fsSL -o "$DL/Native-Access_2.exe" "$NA_URL"
      fi

      echo ">> running the Native Access installer (click through it)"
      cd "$DL"
      wine Native-Access_2.exe >>"$LOG" 2>&1 || true
      wineserver -w

      NA="$WINEPREFIX/drive_c/Program Files/Native Instruments/Native Access"
      if [ ! -f "$NA/Native Access.exe" ]; then
        echo "!! Native Access did not install. See $LOG" >&2
        exit 1
      fi

      # NA wants UAC to install its dependencies, which wine cannot give it.
      # It ships the daemon installer itself, so run that directly.
      echo ">> installing NTK daemon"
      DAEMON="$(find "$NA/resources/daemon/win" -iname '*Setup PC.exe' 2>/dev/null | head -1)"
      if [ -n "$DAEMON" ]; then
        cd "$(dirname "$DAEMON")"
        wine "$DAEMON" >>"$LOG" 2>&1 || true
        wineserver -w
      else
        echo "!! no NTK daemon installer found under $NA/resources/daemon/win" >&2
      fi

      echo
      echo ">> done. Next:"
      echo "   1. ni-access          log in and reinstall your libraries"
      echo "   2. ni-refresh-plugins build the plugin-side copy"
      echo "   3. rescan VSTs in REAPER"
    '';
  };
in
{
  environment.systemPackages = [
    naWine
    pkgs-unstable.winetricks
    shim
    ni-access
    ni-refresh-plugins
    install-win-plugin
    ni-bootstrap-prefix
  ];

  # The stale March desktop entry points at the old prefix and omits
  # --disable-gpu, which gives a blank window. This one calls the wrapper.
  environment.etc."xdg/applications/native-access.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Native Access
    Comment=Native Instruments product manager (wine)
    Exec=${ni-access}/bin/ni-access
    Icon=native-access
    Terminal=false
    Categories=AudioVideo;Audio;
  '';
}
