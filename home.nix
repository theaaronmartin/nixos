{ lib
, config
, osConfig
, ...
}:
{
  imports = [
    ./modules/hm-dev.nix
  ];

  home.stateVersion = "25.11";

  home.sessionVariables = {
    NODE_PATH = "${config.home.homeDirectory}/.npm-packages/lib/node_modules";
  };

  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-packages
  '';

  home.sessionPath = [
    "$HOME/.local/bin"
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

    # --- Host-specific Aliases ---
    (lib.mkIf (osConfig.networking.hostName == "NIXCORE") {
      nix-switch = "sudo nixos-rebuild switch --flake ~/nixos#NIXCORE";
      set-colors = "openrgb --device 0 --mode static --color FF0026 --device 1 --mode static --color FF0026 --device 2 --mode direct --color FF0026 --device 3 --zone 1 --size 30 --zone 2 --size 30 --mode static --color 5D00FF";
      dayz = "steam-run ${config.home.homeDirectory}/Games/arma3-unix-launcher/build/src/dayz-linux-launcher/dayz-linux-launcher";
    })

    (lib.mkIf (osConfig.networking.hostName == "SHELL") {
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
      export ANTHROPIC_KEY=$(cat /run/secrets/anthropic_key)
      export DEEPSEEK_KEY=$(cat /run/secrets/deepseek_key)
      export PATH="$HOME/.local/bin:$PATH"
      setopt NO_CASE_GLOB

      [[ ! -r '${config.home.homeDirectory}/.opam/opam-init/init.zsh' ]] || source '${config.home.homeDirectory}/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
    
      eval "$(direnv hook zsh)"
    '';
  };
}
