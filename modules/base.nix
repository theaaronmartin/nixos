{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Core utilities from users.nix and home.nix
    parted
    wget
    curl
    git

    # Additional core utilities
    btop
    tree
    file
    which
    rsync
    unzip
    zip
    p7zip
    tmux
  ];
}

