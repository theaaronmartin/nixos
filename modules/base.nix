{ pkgs, ... }:
{
  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    trusted-users = [
      "root"
      "plague"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  environment.systemPackages = with pkgs; [
    parted
    wget
    curl
    git
    vim
    tmux
    jq
    tree
    file
    which
    rsync
    unzip
    zip
    p7zip
  ];
}
