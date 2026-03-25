{ config, pkgs, ... }: {

  security.rtkit.enable = true; 

  environment.systemPackages = [
    pkgs.pipewire.jack
    pkgs.wineWowPackages.staging
    (pkgs.buildFHSEnv {
      name = "ni-zone";
      targetPkgs = pkgs: with pkgs; [
        wineWowPackages.staging
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
      runScript = "bash";
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
}
