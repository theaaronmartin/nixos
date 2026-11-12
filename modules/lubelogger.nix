# LubeLogger vehicle maintenance and fuel tracker. Added 2026-11-11.
# NIXCORE only. Reachable from SHELL and the rest of the LAN at
# http://192.168.0.198:5000.
#
# Uses the nixpkgs module (services.lubelogger, in nixos-26.05). State such as
# the LiteDB database, uploaded documents and config lives in
# /var/lib/lubelogger.
#
# The upstream module hard-codes Kestrel's URL to http://localhost:<port>, so
# openFirewall on its own opens a port that nothing is listening on. The
# Kestrel URL below overrides it, because the module merges `settings` over
# its own environment with `//`.
#
# LubeLogger starts with authentication OFF. Turn it on under
# Settings -> Enable Authentication on first visit. That creates the root user.
{ config, ... }:

let
  port = config.services.lubelogger.port;
in
{
  services.lubelogger = {
    enable = true;
    port = 5000;
    openFirewall = true;
    settings = {
      Kestrel__Endpoints__Http__Url = "http://0.0.0.0:${toString port}";
    };
  };
}
