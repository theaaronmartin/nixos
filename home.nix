{ config, pkgs, inputs, ... }: 
let
  secrets = import ./secrets.nix;
in {
  home.stateVersion = "25.11";


  home.sessionVariables = {
    NODE_PATH = "$HOME/.npm-packages/lib/node_modules";
  };

  home.file.".npmrc".text = ''
    prefix=/home/plague/.npm-packages
  '';

  home.sessionPath = {
    "$HOME/.npm-packages/bin"
  };

  home.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ~/nixos-config#NIXCORE";
    nix-clean = "sudo nix-collect-garbage -d";
    vstsync = "yabridgectl sync";
    oc-deep = "CLAUDE_CODE_USE_OPENAI=1 OPENAI_API_KEY='${secrets.deepseekKey}' OPENAI_BASE_URL='https://api.deepseek.com/v1' OPENAI_MODEL='deepseek-chat' openclaude";
    oc-sonnet = "CLAUDE_CODE_USE_OPENAI=1 OPENAI_API_KEY='${secrets.anthropicKey}' OPENAI_BASE_URL='https://api.anthropic.com/v1' OPENAI_MODEL='claude-3-5-sonnet-20240620' openclaude";
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

}
