{ lib
, config
, osConfig
, pkgs
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
      if [ -f ~/.config/secrets.env ]; then
          source ~/.config/secrets.env
      fi
      setopt NO_CASE_GLOB
    '';
  };

  # The Background Sync Service (Multi-host safe)
  systemd.user.services.notes-autosync = {
    Unit.Description = "Auto-sync notes repository";
    Service = {
      Type = "oneshot";
      # Using -C ensures it works regardless of where your shell is sitting
      ExecStart = "${pkgs.git}/bin/git -C %h/notes pull --rebase && ${pkgs.git}/bin/git -C %h/notes add . && ${pkgs.git}/bin/git -C %h/notes commit -m 'auto-sync from ${builtins.getEnv "HOSTNAME"}' && ${pkgs.git}/bin/git -C %h/notes push";
    };
  };

  systemd.user.timers.notes-autosync = {
    Timer.OnUnitActiveSec = "15m";
    Timer.OnBootSec = "5m";
    Install.WantedBy = [ "timers.target" ];
  };
}
