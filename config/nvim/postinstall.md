# Neovim Postinstall

## Treesitter

The maintained `neovim-treesitter/nvim-treesitter` rewrite needs the
`tree-sitter` CLI to build parsers that are not available as prebuilt shared
objects.

```shell
yay -S tree-sitter-cli
```

Install it with your system package manager, then run this inside Neovim:

```vim
:TSInstallConfigured
```

The config no longer installs parsers automatically on startup, so opening
Neovim will not fail when the CLI is missing.
