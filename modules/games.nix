{ pkgs, ... }:

let
  starsector-env = pkgs.buildFHSEnv {
    name = "starsector-env";
    targetPkgs =
      pkgs: with pkgs; [
        xorg.libX11
        xorg.libXext
        xorg.libXcursor
        xorg.libXrandr
        xorg.libXrender
        xorg.libXxf86vm
        xorg.libXtst
        xorg.libXi
        xorg.libXinerama

        zlib
        glib

        # Graphics & Sound
        libGL
        alsa-lib
        openal
        fontconfig
      ];
    runScript = "./starsector.sh";
  };
in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    steam-run
    mangohud

    lutris
    protonup-qt

    # Updated launcher using the surgical environment
    (writeShellScriptBin "play-starsector" ''
      cd /mnt/games/starsector
      ${starsector-env}/bin/starsector-env
    '')
  ];
}
