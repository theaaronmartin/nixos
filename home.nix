{
  pkgs,
  lib,
  hostName,
  ...
}:
{
  imports = [
    ./modules/hm-dev.nix
  ];

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

  home.shellAliases = lib.mkMerge [
    # --- Common Aliases ---
    {
      nix-clean = "sudo nix-collect-garbage -d";

      # OpenClaude aliases
      oc-deep = "CLAUDE_CODE_USE_OPENAI=1 OPENAI_API_KEY=$DEEPSEEK_KEY OPENAI_BASE_URL='https://api.deepseek.com/v1' OPENAI_MODEL='deepseek-chat' openclaude";
      oc-god = "CLAUDE_CODE_USE_OPENAI=1 OPENAI_API_KEY=$DEEPSEEK_KEY OPENAI_BASE_URL='https://api.deepseek.com/v1' OPENAI_MODEL='deepseek-reasoner' openclaude";
      oc-sonnet = "OPENAI_API_KEY=$ANTHROPIC_KEY openclaude";
      oc-gemma = "CLAUDE_CODE_USE_OPENAI=1 OPENAI_BASE_URL='http://localhost:11434/v1' OPENAI_MODEL=nixgemma:latest openclaude";
    }

    # --- NIXCORE specific Aliases ---
    (lib.mkIf (hostName == "NIXCORE") {
      nix-switch = "sudo nixos-rebuild switch --flake ~/nixos#NIXCORE";
      set-colors = "openrgb --device 0 --mode static --color FF0026 --device 1 --mode static --color FF0026 --device 2 --mode direct --color FF0026 --device 3 --zone 1 --size 30 --zone 2 --size 30 --mode static --color 5D00FF";
      dayz = "steam-run $HOME/Games/arma3-unix-launcher/build/src/dayz-linux-launcher/dayz-linux-launcher";
    })

    # --- SHELL specific Aliases ---
    (lib.mkIf (hostName == "SHELL") {
      nix-switch = "sudo nixos-rebuild switch --flake ~/nixos#SHELL";
    })
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    initContent = ''
      if [ -f ~/.config/secrets.env ]; then
          source ~/.config/secrets.env
      fi
      setopt NO_CASE_GLOB
    '';
  };

  home.packages = with pkgs; [
    fastfetch
  ];
}
