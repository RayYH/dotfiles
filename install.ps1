#Requires -Version 5.1
# Run as Administrator, or enable Developer Mode for symlink support without elevation.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$DOTFILES = $PSScriptRoot

$timestamp = Get-Date -Format 'yyyyMMddHHmmss'
$BACKUP = Join-Path $DOTFILES "backup\$timestamp"
New-Item -ItemType Directory -Path $BACKUP -Force | Out-Null

function Backup-And-Remove {
    param([string]$Path)
    if (Test-Path $Path) {
        Move-Item -Path $Path -Destination $BACKUP -Force
    }
}

function New-Link {
    param([string]$Link, [string]$Target, [switch]$Directory)
    $type = if ($Directory) { 'Junction' } else { 'SymbolicLink' }
    New-Item -ItemType $type -Path $Link -Target $Target -Force | Out-Null
    Write-Host "linked: $Link -> $Target"
}

# .setuprc
$setuprc = Join-Path $HOME '.setuprc'
if (-not (Test-Path $setuprc)) {
    Copy-Item (Join-Path $DOTFILES '.setuprc') $setuprc
}

# Emacs
$emacsDir = Join-Path $HOME '.emacs.d'
New-Item -ItemType Directory -Path $emacsDir -Force | Out-Null
Get-ChildItem (Join-Path $DOTFILES 'config\emacs') | ForEach-Object {
    $dest = Join-Path $emacsDir $_.Name
    Backup-And-Remove $dest
    New-Link -Link $dest -Target $_.FullName
}

# Neovim — Windows uses %LOCALAPPDATA%\nvim
$nvimDest = Join-Path $env:LOCALAPPDATA 'nvim'
Backup-And-Remove $nvimDest
New-Link -Link $nvimDest -Target (Join-Path $DOTFILES 'config\nvim') -Directory

# Alacritty — Windows uses %APPDATA%\alacritty
$alacrittyDest = Join-Path $env:APPDATA 'alacritty'
Backup-And-Remove $alacrittyDest
New-Link -Link $alacrittyDest -Target (Join-Path $DOTFILES 'config\alacritty') -Directory

# Git
$gitconfig = Join-Path $HOME '.gitconfig'
Backup-And-Remove $gitconfig
Copy-Item (Join-Path $DOTFILES 'config\git\.gitconfig') $gitconfig

$gitignore = Join-Path $HOME '.gitignore'
Backup-And-Remove $gitignore
New-Link -Link $gitignore -Target (Join-Path $DOTFILES 'config\git\.gitignore')

# EditorConfig
$editorconfig = Join-Path $HOME '.editorconfig'
Backup-And-Remove $editorconfig
New-Link -Link $editorconfig -Target (Join-Path $DOTFILES 'config\editorconfig\.editorconfig')

# JetBrains IdeaVim
$ideavimrc = Join-Path $HOME '.ideavimrc'
Backup-And-Remove $ideavimrc
New-Link -Link $ideavimrc -Target (Join-Path $DOTFILES 'config\jetbrains\.ideavimrc')

# Conda
$condarc = Join-Path $HOME '.condarc'
Backup-And-Remove $condarc
New-Link -Link $condarc -Target (Join-Path $DOTFILES 'config\conda\.condarc')

# Curl
$curlrc = Join-Path $HOME '.curlrc'
Backup-And-Remove $curlrc
New-Link -Link $curlrc -Target (Join-Path $DOTFILES 'config\curl\.curlrc')

# UV — Windows uses %APPDATA%\uv
$uvDir = Join-Path $env:APPDATA 'uv'
New-Item -ItemType Directory -Path $uvDir -Force | Out-Null
$uvToml = Join-Path $uvDir 'uv.toml'
Backup-And-Remove $uvToml
New-Link -Link $uvToml -Target (Join-Path $DOTFILES 'config\uv\uv.toml')

# ShellCheck
$shellcheckrc = Join-Path $HOME '.shellcheckrc'
Backup-And-Remove $shellcheckrc
New-Link -Link $shellcheckrc -Target (Join-Path $DOTFILES 'config\shellcheck\.shellcheckrc')

Write-Host "`nDone. Restart your terminal."
