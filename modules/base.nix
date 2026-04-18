{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    parted
    wget
    curl
    git
    vim
    tmux
    jq

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
