# Dotfiles Backup

This repository contains my personal configuration files for **Neovim**, **WezTerm**, and **Starship**.

## 🚀 Installation Checklist

Follow these steps when setting up on a new machine.

### 1. Prerequisites (Install these first)
- [ ] **Git** (Required to clone this repo)
- [ ] **Nerd Font** (Required for icons in WezTerm/Starship)
    - *Recommendation:* [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads)
    - *Action:* Download, unzip, and install the font files (Select all > Right Click > Install).
- [ ] **Ripgrep** (Required for Neovim Telescope searching)
    - *Windows:* `winget install BurntSushi.ripgrep.MSVC`
    - *Linux:* `sudo apt install ripgrep` (or equivalent)
- [ ] **C Compiler** (Recommended for Neovim Treesitter)
    - *Windows:* `winget install LLVM` (or install Visual Studio Build Tools)
    - *Linux:* `sudo apt install build-essential`

### 2. Core Apps
- [ ] **Neovim** (Text Editor)
- [ ] **WezTerm** (Terminal Emulator)
- [ ] **Starship** (Shell Prompt)

### 3. Clone & Link
Clone this repository to your home folder:
```bash
cd ~
git clone [https://github.com/YOUR_USERNAME/dotfiles.git](https://github.com/YOUR_USERNAME/dotfiles.git)
```

**On Windows (PowerShell Admin):**
```powershell
cd ~
git clone [https://github.com/YOUR_USERNAME/dotfiles.git](https://github.com/YOUR_USERNAME/dotfiles.git)
cd dotfiles
.\install_dotfiles.ps1
```

**On Linux:**
```bash
cd ~
git clone [https://github.com/YOUR_USERNAME/dotfiles.git](https://github.com/YOUR_USERNAME/dotfiles.git)
cd dotfiles
chmod +x install.sh
./install.sh
```

### 4. Post-Install Verification
- [ ] Open **WezTerm**. Does the font look correct? (No weird boxes)
- [ ] Open **Neovim**.
    - It should automatically start downloading plugins (via lazy.nvim/packer).
    - Run `:checkhealth` to see if any tools (like Node.js, Python, or Ripgrep) are missing.

### 5. Troubleshooting
- **Treesitter Errors?** If you see errors about missing parsers or compilers, ensure `clang` or `gcc` is in your PATH.
    - Windows: `winget install LLVM`
    - Linux: `sudo apt install build-essential`
- **Weird Icons?** If the prompt looks broken, you likely missed the **Nerd Font** step. Install it and restart WezTerm.
