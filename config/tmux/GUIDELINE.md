# tmux Usage Guideline

A practical reference for the bindings and behaviors defined in `tmux.conf`.

## Prefix

The prefix key is **`Ctrl+Space`** (not the default `Ctrl+b`).

In this document `<P>` means "press the prefix". Bindings without `<P>` work directly (no prefix needed).

To send the prefix through to a nested tmux session, double-tap it: `Ctrl+Space Ctrl+Space`.

## Conventions

- **Indexes start at 1** for both windows and panes.
- **Vi mode** is used in copy mode and selection.
- New windows/splits inherit the **current pane's working directory**.
- Closing a window automatically **renumbers** the remaining windows.
- Killing a session does **not** detach you — tmux stays attached to the next session.
- Mouse support is **on** (click to focus, drag borders to resize, scroll to enter copy mode).

## Reload Config

| Keys | Action |
|------|--------|
| `<P> r` | Reload `~/.tmux.conf` and show a confirmation message |

## Windows

### Create / Navigate

| Keys | Action |
|------|--------|
| `<P> c` | New window (in current pane's path) |
| `<P> F` | New window running the `t` command (repeatable) |
| `<P> D` | New window opened at `~/Code/rayyh/dotfiles` (repeatable) |
| `<P> n` / `<P> p` | Next / previous window (repeatable) |
| `<P> Ctrl+n` / `<P> Ctrl+p` | Same as above — lets you hold `Ctrl` and tap n/p |
| `Ctrl+h` / `Ctrl+l` (after `<P>`) | Previous / next window (repeatable) |
| `<P> Space` | Toggle between the two most recent windows |

### Rearrange

| Keys | Action |
|------|--------|
| `<P> >` | Swap current window one position to the right and follow it |
| `<P> <` | Swap current window one position to the left and follow it |
| `<P> N` | Same as `>` (repeatable) |
| `<P> P` | Same as `<` (repeatable) |

## Panes

### Split

| Keys | Action |
|------|--------|
| `<P> \|` | Split horizontally (panes side-by-side) |
| `<P> -` | Split vertically (panes stacked) |

Both splits open in the **current pane's working directory**.

### Move Between Panes (vim-aware, no prefix)

These work **without** the prefix and are **aware of Vim/Neovim** — when focus is in a vim split, the keystroke is forwarded to vim so `Ctrl+h/j/k/l` navigates vim splits seamlessly.

| Keys | Action |
|------|--------|
| `Ctrl+h` | Pane / vim split left |
| `Ctrl+j` | Pane / vim split down |
| `Ctrl+k` | Pane / vim split up |
| `Ctrl+l` | Pane / vim split right |
| `Ctrl+Alt+l` | Send the literal `Ctrl+l` (clear screen) — use when `Ctrl+l` would only navigate |

### Move Between Panes (with prefix, repeatable)

Useful when you don't want to interfere with shell/vim:

| Keys | Action |
|------|--------|
| `<P> h / j / k / l` | Select pane left / down / up / right |

## Sessions

| Keys | Action |
|------|--------|
| `<P> ^` | Switch to the previously used session |

## Copy Mode (Vi keys)

Enter copy mode to scroll, search, and copy.

| Keys | Action |
|------|--------|
| `<P> Enter` | Enter copy mode |
| `v` | Begin selection (character-wise) |
| `Ctrl+v` | Toggle rectangular (block) selection |
| `y` | Copy selection and exit copy mode |
| `H` | Jump to start of line |
| `L` | Jump to end of line |
| `Escape` | Cancel / exit copy mode |

Standard vi motions (`h j k l w b 0 $ / ?` etc.) also work.

### Clipboard

`<P> y` (outside copy mode) copies the current tmux buffer to the **system clipboard**. The config auto-detects the right tool:

- **macOS** → `pbcopy`
- **Linux X11** → `xsel` (fallback `xclip`)
- **Wayland** → `wl-copy`
- **Windows / WSL** → `clip.exe` or `/dev/clipboard`

## Buffers (paste history)

| Keys | Action |
|------|--------|
| `<P> b` | List all paste buffers |
| `<P> p` | Paste the most recent buffer (with bracketed-paste) |
| `<P> P` | Choose a buffer to paste from |

## Status Line

- **Left:** current session name
- **Right:** `rayyh` tag
- **Window format:** `<index>󰿟<current command>` — the active window is highlighted
- Activity in other windows is monitored but does not flash a visual bell

## Other Behaviors Worth Knowing

- **Scrollback buffer:** 100,000 lines.
- **Repeat window:** 600 ms — gives generous time for repeatable bindings (`-r`) like `<P> h h h`.
- **Aggressive resize** is on — if you share a session across terminals of different sizes, the active window resizes to the smallest client viewing it (not all clients).
- **Escape time:** 5 ms — keeps vim mode-switching snappy.
- **True color, undercurl, and OSC 8 hyperlinks** are enabled for modern terminals.

## Quick Cheat-Sheet

```
Prefix:           Ctrl+Space
Reload config:    <P> r
New window:       <P> c          New split:       <P> | or <P> -
Next/prev window: <P> n / p      Last window:     <P> Space
Move pane:        Ctrl+h/j/k/l   (vim-aware, no prefix)
Copy mode:        <P> Enter      Select / copy:   v ... y
Paste:            <P> p
Dotfiles window:  <P> D          New `t` window:  <P> F
```
