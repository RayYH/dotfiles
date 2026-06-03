# Emacs Post-Install Checklist

Manual setup required after installing this config on a new machine.

## Emacs Packages

Start Emacs once with network access. `use-package` installs missing packages
from GNU ELPA and MELPA automatically.

If package icons render as boxes, run this inside Emacs:

```text
M-x nerd-icons-install-fonts
```

## Tree-Sitter

This config remaps several major modes to Emacs tree-sitter modes. Install the
configured grammars once:

```text
M-x my/install-treesit-grammars
```

## C / C++

Eglot uses `clangd` for C and C++.

```bash
# Ubuntu/Debian
sudo apt install clangd

# Arch
sudo pacman -S clang

# Fedora
sudo dnf install clang-tools-extra

# macOS
brew install llvm
```

After installing, reopen the C/C++ buffer or run:

```text
M-x eglot
```

## Language Servers

Install the servers for the languages you use:

```bash
# Rust
rustup component add rust-analyzer

# Go
go install golang.org/x/tools/gopls@latest

# Python
pip install pyright
# or:
pip install 'python-lsp-server[all]'

# TypeScript / JavaScript
npm install -g typescript typescript-language-server

# Dockerfile
npm install -g dockerfile-language-server-nodejs

# PHP
composer global require intelephense
# or install phpactor

# C#
dotnet tool install -g csharp-ls

# Lua
brew install lua-language-server
```

For Java, install Eclipse JDT LS and make sure it is discoverable by Eglot.

## Spell Checking

Flyspell is configured to use Hunspell with the `en_US` dictionary.

```bash
# Ubuntu/Debian
sudo apt install hunspell hunspell-en-us

# Arch
sudo pacman -S hunspell hunspell-en_us

# Fedora
sudo dnf install hunspell hunspell-en-US

# macOS
brew install hunspell
```

If the OS package does not install `en_US`, download the Hunspell dictionary
files manually. Hunspell dictionaries are a pair of `.aff` and `.dic` files.

```bash
mkdir -p ~/.local/share/hunspell

curl -L -o ~/.local/share/hunspell/en_US.aff \
  'https://cgit.freedesktop.org/libreoffice/dictionaries/plain/en/en_US.aff?id=a4473e06b56bfe35187e302754f6baaa8d75e54f'

curl -L -o ~/.local/share/hunspell/en_US.dic \
  'https://cgit.freedesktop.org/libreoffice/dictionaries/plain/en/en_US.dic?id=a4473e06b56bfe35187e302754f6baaa8d75e54f'
```

If Hunspell still cannot find the dictionary, inspect its search paths:

```bash
hunspell -D
```

Copy `en_US.aff` and `en_US.dic` into one of the listed dictionary paths, or
set `DICPATH` to the directory that contains them.

Test it with:

```bash
printf 'example\nteached\n' | hunspell -d en_US
```

## Org LaTeX Preview

Org LaTeX previews use `dvisvgm`. Install it through your TeX distribution.

```bash
sudo tlmgr install dvisvgm
```

## External Search Tools

Some Consult commands are best with these tools available on `PATH`:

```bash
# ripgrep powers consult-ripgrep
rg --version

# fd powers consult-fd
fd --version
```
