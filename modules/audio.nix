{ pkgs, ... }:
{

  security.rtkit.enable = true;

  environment.systemPackages = [
    pkgs.pipewire.jack
    pkgs.reaper

    # Windows VST2/VST3 bridge for REAPER. Keeps the wine 9.21 that nixpkgs
    # pins it to; yabridge does not work on wine 10+ (editors render but
    # ignore all mouse input). Native Access needs wine 11 and therefore lives
    # in modules/native-instruments.nix with its own wine. Note iLok-authorized
    # plugins still will not work - PACE has no Linux support.
    pkgs.yabridge
    pkgs.yabridgectl

    (pkgs.stdenv.mkDerivation {
      pname = "decent-sampler-manual";
      version = "1.17.1";

      src = ./Decent_Sampler-1.17.1-Linux-Static-x86_64.tar.gz;

      nativeBuildInputs = [
        pkgs.autoPatchelfHook
        pkgs.wrapGAppsHook3
      ];

      buildInputs = [
        pkgs.alsa-lib
        pkgs.freetype
        pkgs.libGL
        pkgs.xorg.libX11
        pkgs.stdenv.cc.cc.lib
      ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $out/lib/vst3 $out/lib/vst

        if [ -f DecentSampler ]; then
          cp DecentSampler $out/bin/
          cp -r DecentSampler.vst3 $out/lib/vst3/
          [ -f DecentSampler.so ] && cp DecentSampler.so $out/lib/vst/
        else
          cp */DecentSampler $out/bin/
          cp -r */DecentSampler.vst3 $out/lib/vst3/
          [ -f */DecentSampler.so ] && cp */DecentSampler.so $out/lib/vst/
        fi

        runHook postInstall
      '';
    })
  ];

  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "95";
    }
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # Pro Audio latency tweaks
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 128;
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 1024;
      };
    };
  };

}
