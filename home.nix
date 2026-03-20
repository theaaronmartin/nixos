{ config, pkgs, ... }: {
  home.stateVersion = "25.11";

  home.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ~/nixos-config#NIXCORE";
    nix-clean = "sudo nix-collect-garbage -d";
  };

  programs.bash.enable = true;

  programs.wezterm.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  # Symlink your Neovim and WezTerm folders directly
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/plague/nixos-config/dotfiles/nvim";
  xdg.configFile."wezterm".source = config.lib.file.mkOutOfStoreSymlink "/home/plague/nixos-config/dotfiles/wezterm";

  # List user-specific packages (LSPs, CLI tools)
  home.packages = with pkgs; [
    ripgrep
    fd
    gcc
    lua-language-server
    nil
  ];
}
