# Check for Administrator privileges (required for symlinks on Windows)
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as Administrator!" -ForegroundColor Red
    exit
}

$dotfiles = "$HOME\dotfiles"
$config = "$HOME\.config"

# Ensure .config directory exists
if (!(Test-Path -Path $config)) {
    New-Item -ItemType Directory -Path $config | Out-Null
}

# Function to safely link folders
function Link-Config {
    param (
        [string]$Name,
        [string]$Source,
        [string]$Target
    )

    # 1. Check if the backup target exists
    if (Test-Path -Path $Target) {
        Write-Host "Found existing $Name config..." -ForegroundColor Yellow
        
        # Check if it is already a symlink
        $isLink = (Get-Item $Target).Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint)
        
        if ($isLink) {
            Write-Host "It is already a symlink. Skipping." -ForegroundColor Green
            return
        } else {
            # Backup existing real folder
            $backup = "$Target.backup.$(Get-Date -Format 'yyyyMMddHHmm')"
            Rename-Item -Path $Target -NewName $backup
            Write-Host "Backed up existing $Name to $backup" -ForegroundColor Cyan
        }
    }

    # 2. Create the Symlink
    New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
    Write-Host "Linked $Name successfully!" -ForegroundColor Green
}

# Run the linker for your tools
Link-Config -Name "Neovim"  -Source "$dotfiles\nvim"          -Target "$config\nvim"
Link-Config -Name "WezTerm" -Source "$dotfiles\wezterm"       -Target "$config\wezterm"
Link-Config -Name "Starship" -Source "$dotfiles\starship.toml" -Target "$config\starship.toml"

Write-Host "`nSetup Complete!" -ForegroundColor Green
