{ pkgs, config, ... }: {
  environment.systemPackages = with pkgs; [ sops ];

  sops = {
    age.keyFile = "/home/plague/.config/sops/age/keys.txt";

    secrets = {
      anthropic_key = {
        sopsFile = ../secrets/secrets.yaml;
      };
      deepseek_key = {
        sopsFile = ../secrets/secrets.yaml;
      };
      radarr_key = {
        sopsFile = ../secrets/secrets.yaml;
      };
      sonarr_key = {
        sopsFile = ../secrets/secrets.yaml;
      };
      nd_lastfm_apikey = {
        sopsFile = ../secrets/secrets.yaml;
      };
      nd_lastfm_secret = {
        sopsFile = ../secrets/secrets.yaml;
      };
    };
    templates."navidrome.env" = {
      content = ''
        ND_LASTFM_ENABLED=TRUE
        ND_LASTFM_APIKEY=${config.sops.placeholder.nd_lastfm_apikey}
        ND_LASTFM_SECRET=${config.sops.placeholder.nd_lastfm_secret}
      '';
      path = "/var/lib/navidrome/navidrome.env";
    };
  };
}
