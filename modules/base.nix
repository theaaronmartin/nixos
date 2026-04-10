{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    parted
    wget
    curl
    git
    vim
    tmux

    btop
    tree
    file
    which
    rsync
    unzip
    zip
    p7zip
  ];
}
