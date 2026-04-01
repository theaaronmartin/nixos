{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    # The "Magic Bullet" for non-Nix binaries (Starsector, etc.)
    steam-run 
    
    # Your custom Starsector Launcher (The Read-Only Fix)
    (writeShellScriptBin "play-starsector" ''
      cd /mnt/games/starsector
      # Use steam-run to provide the missing libraries (libXrender, etc.)
      ${steam-run}/bin/steam-run ./starsector.sh
    '')
  ];
}
