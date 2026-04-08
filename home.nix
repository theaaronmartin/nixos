{
  config,
  pkgs,
  ...
}:
{
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
    oc-deep = "CLAUDE_CODE_USE_OPENAI=1 OPENAI_API_KEY=$DEEPSEEK_KEY OPENAI_BASE_URL='https://api.deepseek.com/v1' OPENAI_MODEL='deepseek-chat' /home/plague/.npm-packages/bin/openclaude";
    oc-sonnet = "OPENAI_API_KEY=$ANTHROPIC_KEY /home/plague/.npm-packages/bin/openclaude";
    oc-llama = "CLAUDE_CODE_USE_OPENAI=1 OPENAI_BASE_URL='http://localhost:11434/v1' OPENAI_MODEL=llama3.1:8b";
    oc-phi = "CLAUDE_CODE_USE_OPENAI=1 OPENAI_BASE_URL='http://localhost:11434/v1' OPENAI_MODEL=phi3:mini";
    oc-code = "CLAUDE_CODE_USE_OPENAI=1 OPENAI_BASE_URL='http://localhost:11434/v1' OPENAI_MODEL=codellama:7b";

    # Ollama aliases
    ollama-status = "sudo systemctl status ollama";
    ollama-logs = "sudo journalctl -u ollama -f";
    ollama-start = "sudo systemctl start ollama";
    ollama-stop = "sudo systemctl stop ollama";
    ollama-restart = "sudo systemctl restart ollama";

    # Model-specific aliases
    phi = "ollama run phi3:mini";
    llama = "ollama run llama3.1:8b";
    llama-small = "ollama run llama3.2:3b";
    code = "ollama run codellama:13b";
    code-small = "ollama run codellama:7b";

    # Quick chat with each model
    phi-chat = "ollama run phi3:mini --verbose";
    llama-chat = "ollama run llama3.1:8b --verbose";
    llama-small-chat = "ollama run llama3.2:3b --verbose";
    code-chat = "ollama run codellama:13b --verbose";
    code-small-chat = "ollama run codellama:7b --verbose";

    # Pull commands
    pull-phi = "ollama pull phi3:mini";
    pull-llama = "ollama pull llama3.1:8b";
    pull-llama-small = "ollama pull llama3.2:3b";
    pull-code = "ollama pull codellama:13b";
    pull-code-small = "ollama pull codellama:7b";

    # List and manage
    ollama-list = "ollama list";
    ollama-ps = "ollama ps";
    ollama-rm = "ollama rm";
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
    settings = builtins.fromTOML (builtins.readFile ./dotfiles/starship.toml);
  };

  # Symlink your Neovim and WezTerm folders directly
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/home/plague/nixos-config/dotfiles/nvim";
  xdg.configFile."wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "/home/plague/nixos-config/dotfiles/wezterm";

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
    clang-tools
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
