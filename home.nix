{ config, pkgs, ... }: {
  home.stateVersion = "25.11";

  # Symlink your Neovim and WezTerm folders directly
  xdg.configFile."nvim".source = ./dotfiles/nvim;
  xdg.configFile."wezterm".source = ./dotfiles/wezterm;

  # List user-specific packages (LSPs, CLI tools)
  home.packages = with pkgs; [
    ripgrep
    fd
    gcc
    lua-language-server
    nil
  ];
}
