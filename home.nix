{ config, pkgs, inputs, ... }: {
  home.stateVersion = "25.11";


  home.sessionVariables = {
    NODE_PATH = "$HOME/.npm-packages/lib/node_modules";
  };

  home.file.".npmrc".text = ''
    prefix=/home/plague/.npm-packages
  '';

  home.sessionPath = [
    "$HOME/.npm-packages/bin"
  ];

  home.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ~/nixos-config#NIXCORE";
    nix-clean = "sudo nix-collect-garbage -d";
    vstsync = "yabridgectl sync";
    oc-deep = "CLAUDE_CODE_USE_OPENAI=1 OPENAI_API_KEY='$DEEPSEEK_KEY' OPENAI_BASE_URL='https://api.deepseek.com/v1' OPENAI_MODEL='deepseek-chat' /home/plague/.npm-packages/bin/openclaude";
    oc-sonnet = "OPENAI_API_KEY='$ANTHROPIC_KEY' OPENAI_MODEL='claude-3-5-sonnet-20240620' /home/plague/.npm-packages/bin/openclaude";
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      if [ -f ~/.config/secrets.env ]; then
          source ~/.config/secrets.env
      fi
    '';
  };

  programs.wezterm.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  programs.starship = {
    enable = true;
    settings = (
      import builtins.fromTOML (builtins.readFile ./dotfiles/starship.toml)
    );
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
    curl
    git
    fastfetch
    libreoffice-qt-fresh
    hunspell
    hunspellDicts.en_US-large
    nodejs_20
  ];

}
