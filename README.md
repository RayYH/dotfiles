# Dotfiles

> [!CAUTION]
> DO NOT BLINDLY USE MY DOTFILES. I STRONGLY RECOMMEND YOU TO READ THROUGH THE FILES AND UNDERSTAND WHAT YOU ARE DOING.

## Prerequisites

Git must be installed before cloning this repository.

**macOS**

```bash
xcode-select --install
```

**Ubuntu**

```bash
sudo apt install git
```

**Arch Linux**

```bash
sudo pacman -S git
```

## Installation

```bash
git clone https://github.com/rayyh/dotfiles
cd dotfiles
yes | ./bootstrap.sh
./install.sh
```

Reload your shell and you are good to go.

## Supported Platforms

- macOS
- Ubuntu
- Arch Linux

## Credits

I've borrowed a lot of ideas from the following repositories:

- [jessarcher/dotfiles](https://github.com/jessarcher/dotfiles)
- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
- [gpakosz/.tmux](https://github.com/gpakosz/.tmux)
- [ntegralist/nvim](https://github.com/Integralist/nvim)
- [josean-dev/dev-environment-files](https://github.com/josean-dev/dev-environment-files)
