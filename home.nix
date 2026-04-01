{ config, pkgs, inputs, ... }: {
  home.stateVersion = "25.11";

  home.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ~/nixos-config#NIXCORE";
    nix-clean = "sudo nix-collect-garbage -d";
    vstsync = "yabridgectl sync";
    ni-start = "ni-zone -c 'export WINEPREFIX=$HOME/.wine-ni; bash'";
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
    typescript-language-server
    yaml-language-server
    biome
    llvmPackages.clang-unwrapped
    reaper
    yabridge
    yabridgectl
    wget
    fastfetch
    libreoffice-qt-fresh
    hunspell
    hunspellDicts.en_US-large
    nodejs_20
  ];

  home.sessionVariables = {
    NODE_PATH = "$HOME/.npm-packages/lib/node_modules";
  }

  home.file.".npmrc".text = ''
    prefix=\${HOME}/.npm-packages
  '';
}
