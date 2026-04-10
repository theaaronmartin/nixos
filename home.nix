{ pkgs, ... }:
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

  home.shellAliases = {
    nix-switch = "sudo nixos-rebuild switch --flake ~/nixos-config#NIXCORE";
    nix-clean = "sudo nix-collect-garbage -d";

    # OpenClaude aliases
    oc-deep = "CLAUDE_CODE_USE_OPENAI=1 OPENAI_API_KEY=$DEEPSEEK_KEY OPENAI_BASE_URL='https://api.deepseek.com/v1' OPENAI_MODEL='deepseek-chat' /home/plague/.npm-packages/bin/openclaude";
    oc-god = "CLAUDE_CODE_USE_OPENAI=1 OPENAI_API_KEY=$DEEPSEEK_KEY OPENAI_BASE_URL='https://api.deepseek.com/v1' OPENAI_MODEL='deepseek-reasoner' /home/plague/.npm-packages/bin/openclaude";
    oc-sonnet = "OPENAI_API_KEY=$ANTHROPIC_KEY /home/plague/.npm-packages/bin/openclaude";
    oc-gemma = "CLAUDE_CODE_USE_OPENAI=1 OPENAI_BASE_URL='http://localhost:11434/v1' OPENAI_MODEL=nixgemma:latest /home/plague/.npm-packages/bin/openclaude";
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      if [ -f ~/.config/secrets.env ]; then
          source ~/.config/secrets.env
      fi
    '';
  };

  home.packages = with pkgs; [
    fastfetch
  ];
}
