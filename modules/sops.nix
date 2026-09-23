# Base secrets: the age key plus the three API keys home.nix reads in zsh init.
# Media-stack secrets live in sops-media.nix (NIXCORE only).
#
# NOTE for a fresh SHELL install: home.nix unconditionally cats
# /run/secrets/anthropic_key, /run/secrets/deepseek_key and
# /run/secrets/typesafe_key from zsh. Get the age keyfile below onto the machine
# BEFORE the first nixos-rebuild, or activation fails and every new shell throws.
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ sops ];

  sops = {
    age.keyFile = "/home/plague/.config/sops/age/keys.txt";

    secrets = {
      anthropic_key = {
        sopsFile = ../secrets/secrets.yaml;
        owner = "plague";
      };
      deepseek_key = {
        sopsFile = ../secrets/secrets.yaml;
        owner = "plague";
      };
      # TypeSafe/Jev, read by ~/.claude/scripts/jev-route for /dispatch model routing.
      typesafe_key = {
        sopsFile = ../secrets/secrets.yaml;
        owner = "plague";
      };
    };
  };
}
