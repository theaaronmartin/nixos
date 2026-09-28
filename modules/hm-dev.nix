{ config, ... }:
{
  programs.wezterm.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    # home-manager 26.05 writes the provider setup (python3/ruby host_prog,
    # node/perl disabled) to ~/.config/nvim/init.lua. That path is the
    # mkOutOfStoreSymlink below, which resolves outside $HOME and makes the
    # home-manager-files build fail. Sideloading passes the same lua via
    # `--cmd` before init.lua is read, so the dotfiles stay a live symlink.
    sideloadInitLua = true;
  };

  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ../dotfiles/starship.toml);
  };

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/nvim";
  xdg.configFile."wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dotfiles/wezterm";
}
