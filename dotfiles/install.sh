#!/bin/bash

DOTFILES="$HOME/dotfiles"
CONFIG="$HOME/.config"

mkdir -p "$CONFIG"

link_config() {
    NAME=$1
    SOURCE=$2
    TARGET=$3

    # Check if target exists
    if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
        # Check if it's already a symlink pointing to the right place
        if [ -L "$TARGET" ] && [ "$(readlink -f "$TARGET")" = "$SOURCE" ]; then
            echo "✅ $NAME is already linked."
            return
        fi

        # Backup existing file/folder if it's not our link
        BACKUP="${TARGET}.backup.$(date +%Y%m%d%H%M)"
        mv "$TARGET" "$BACKUP"
        echo "⚠️  Existing $NAME moved to $BACKUP"
    fi

    # Create the symlink
    ln -s "$SOURCE" "$TARGET"
    echo "🔗 Linked $NAME"
}

link_config "Neovim"  "$DOTFILES/nvim"          "$CONFIG/nvim"
link_config "WezTerm" "$DOTFILES/wezterm"       "$CONFIG/wezterm"
link_config "Starship" "$DOTFILES/starship.toml" "$CONFIG/starship.toml"

echo -e "\nSetup Complete!"
