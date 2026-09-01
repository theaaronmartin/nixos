# Media-stack secrets and rendered config. Split out of sops.nix (2026-09-01):
# SHELL imports sops.nix for the API keys and has no business decrypting arr
# tokens or rendering a navidrome env file for a service it does not run.
# NIXCORE only.
{ config, ... }:
{
  sops = {
    secrets = {
      radarr_key = {
        sopsFile = ../secrets/secrets.yaml;
        owner = "plague";
      };
      sonarr_key = {
        sopsFile = ../secrets/secrets.yaml;
        owner = "plague";
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

    templates."managarr.yml" = {
      content = ''
        radarr:
          - host: 192.168.0.198
            port: 7878
            api_token_file: ${config.sops.secrets.radarr_key.path}
        sonarr:
          - host: 192.168.0.198
            port: 8989
            api_token_file: ${config.sops.secrets.sonarr_key.path}
      '';
      path = "/home/plague/.config/managarr/config.yml";
      owner = "plague";
    };
  };
}
