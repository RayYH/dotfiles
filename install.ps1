#Requires -Version 5.1
# Run as Administrator, or enable Developer Mode for symlink support without elevation.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$DOTFILES = $PSScriptRoot

$timestamp = Get-Date -Format 'yyyyMMddHHmmss'
$BACKUP = Join-Path $DOTFILES "backup\$timestamp"
New-Item -ItemType Directory -Path $BACKUP -Force | Out-Null

# Unix dest paths that resolve differently on Windows
$PathOverrides = @{
    '~/.config/nvim'       = "$env:LOCALAPPDATA\nvim"
    '~/.config/alacritty'  = "$env:APPDATA\alacritty"
    '~/.config/uv/uv.toml' = "$env:APPDATA\uv\uv.toml"
}

# MANIFEST src prefixes that do not apply on Windows
$SkipSrc = @('config/kitty', 'config/tmux', 'config/starship', 'config/wget', 'scripts/')

function Backup-And-Remove {
    param([string]$Path)
    if (-not (Test-Path $Path -ErrorAction SilentlyContinue)) { return }
    $item = Get-Item $Path -Force
    if ($item.LinkType -in ('SymbolicLink', 'Junction')) {
        $real = $item.Target
        if ($real -and (Test-Path $real)) {
            Copy-Item $real (Join-Path $BACKUP $item.Name) -Recurse -Force
        }
        Remove-Item $Path -Force -Recurse
    } else {
        Move-Item -Path $Path -Destination $BACKUP -Force
    }
}

function Install-Entry {
    param([string]$Src, [string]$Dest, [string]$Op = 'link')

    $parent = Split-Path $Dest -Parent
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if ($Op -eq 'copy' -and (Test-Path $Dest)) {
        $answer = Read-Host "$Dest already exists. Override? [y/N]"
        if ($answer -notmatch '^[Yy]$') {
            Write-Host "Skipping $Dest"
            return
        }
    }

    Backup-And-Remove $Dest

    if ($Op -eq 'copy') {
        Copy-Item $Src $Dest
        Write-Host "copied: $Src -> $Dest"
    } else {
        $type = if (Test-Path $Src -PathType Container) { 'Junction' } else { 'SymbolicLink' }
        New-Item -ItemType $type -Path $Dest -Target $Src -Force | Out-Null
        Write-Host "linked: $Dest -> $Src"
    }
}

# .setuprc
$setuprc = Join-Path $HOME '.setuprc'
if (-not (Test-Path $setuprc)) {
    Copy-Item (Join-Path $DOTFILES '.setuprc') $setuprc
}

# Read MANIFEST
Get-Content (Join-Path $DOTFILES 'MANIFEST') | ForEach-Object {
    $line = $_.Trim()
    if ($line -match '^#' -or $line -eq '') { return }
    if ($line -notmatch '^(.+?)\s*->\s*(\S+)(?:\s+(\S+))?$') { return }

    $src  = $Matches[1].TrimEnd()
    $dest = $Matches[2]
    $op   = if ($Matches[3]) { $Matches[3] } else { 'link' }

    foreach ($skip in $SkipSrc) {
        if ($src.StartsWith($skip)) { return }
    }

    # Handle glob (src/*)
    if ($src.EndsWith('/*')) {
        $srcDir      = Join-Path $DOTFILES ($src.TrimEnd('/*') -replace '/', '\')
        $destExpanded = $dest -replace '^~', $HOME
        New-Item -ItemType Directory -Path $destExpanded -Force | Out-Null
        Get-ChildItem $srcDir | ForEach-Object {
            $itemDest = Join-Path $destExpanded $_.Name
            Backup-And-Remove $itemDest
            $type = if ($_.PSIsContainer) { 'Junction' } else { 'SymbolicLink' }
            New-Item -ItemType $type -Path $itemDest -Target $_.FullName -Force | Out-Null
            Write-Host "linked: $itemDest -> $($_.FullName)"
        }
        return
    }

    $srcResolved  = Join-Path $DOTFILES ($src -replace '/', '\')
    $destResolved = if ($PathOverrides.ContainsKey($dest)) {
        $PathOverrides[$dest]
    } else {
        ($dest -replace '^~', $HOME) -replace '/', '\'
    }

    Install-Entry -Src $srcResolved -Dest $destResolved -Op $op
}

Write-Host "`nDone. Restart your terminal."
