{ config, pkgs, ... }:
{

  programs.wezterm.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./dotfiles/starship.toml);
  };

  # Symlink your Neovim and WezTerm folders directly
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/home/plague/nixos-config/dotfiles/nvim";
  xdg.configFile."wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "/home/plague/nixos-config/dotfiles/wezterm";

  dev.packages = with pkgs; [
    ripgrep
    fd
    gcc
    lua-language-server
    nil
    typescript-language-server
    yaml-language-server
    biome
    clang-tools
    nodejs_20
    opencode
  ];
}
