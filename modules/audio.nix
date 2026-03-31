{ config, pkgs, ... }: {

  security.rtkit.enable = true; 

  environment.systemPackages = [
    pkgs.pipewire.jack
    pkgs.wineWowPackages.staging
    (pkgs.stdenv.mkDerivation {
      pname = "decent-sampler-manual";
      version = "1.17.1";
      
      # PASTE THE PATH YOU GOT FROM STEP 1 HERE
      src = ./Decent_Sampler-1.17.1-Linux-Static-x86_64.tar.gz; 

      nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.wrapGAppsHook3 ];
      
      # Even 'static' builds need these core Linux windowing libs
      buildInputs = [ 
        pkgs.alsa-lib 
        pkgs.freetype 
        pkgs.libGL 
        pkgs.xorg.libX11 
        pkgs.stdenv.cc.cc.lib
      ];

      unpackPhase = "tar -xzf $src";

      installPhase = ''
        mkdir -p $out/bin $out/lib/vst3 $out/lib/vst
        
        # Install the standalone app
        cp DecentSampler $out/bin/
        
        # Install the VST3 folder
        cp -r DecentSampler.vst3 $out/lib/vst3/
        
        # Install the VST2 file (if present)
        [ -f DecentSampler.so ] && cp DecentSampler.so $out/lib/vst/
      '';
    })
    (pkgs.buildFHSEnv {
      name = "ni-zone";
      targetPkgs = pkgs: with pkgs; [
        wineWowPackages.staging
        winetricks
        gnutls
        libgpg-error
        p11-kit
        zlib
        libxml2
        libxslt
        icu
        nss
        nspr
        expat
      ];
      runScript = pkgs.writeScript "ni-zone-init" ''
        export PS1="(ni-zone) \u@\h:\w\$ "
        exec bash
      '';
    })
  ];

  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio"; type = "-"; value = "95"; }
  ];
  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true; # Critical for REAPER's performance
    
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

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    pipewire
    alsa-lib
    curl
    gnutls
    zlib
    libGL
    freetype
    glib
    xorg.libX11
    xorg.libXext
    xorg.libSM
    xorg.libICE
    xorg.libXcursor
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXi
  ];
}
