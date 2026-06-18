# Emacs Keymap Quick Reference

Keys defined in `init.el`. Default Emacs bindings not listed unless overridden.
`which-key` is already on — press any prefix and wait 0.5s to see the live
menu.

## Prefix Map

| Prefix    | Domain                              |
|-----------|-------------------------------------|
| `C-c b`   | Buffer navigation                   |
| `C-c h`   | Consult helpers (org agenda/heading) |
| `C-c !`   | Diagnostics (flymake)               |
| `C-c j`   | Jump (top/bottom of buffer)         |
| `C-c l`   | LSP (eglot) — active in code buffers |
| `C-c m`   | Magit                               |
| `C-c n`   | Notes (org-roam)                    |
| `C-c o`   | Org global commands                 |
| `C-c p`   | Project (`project.el`)              |
| `C-c r`   | Recent files                        |
| `C-c t`   | Toggles                             |
| `C-c z`   | Code folding (hideshow)             |
| `C-c 4`   | Perforce                            |
| `C-c C-`  | Multiple cursors / mode-local       |

---

## Editing

| Key             | Command                            |
|-----------------|------------------------------------|
| `C-x ,`         | `duplicate-dwim` (line/region)     |
| `C-x r`         | `undo-redo`                        |
| `C-x u`         | `vundo` (visual undo tree)         |
| `C-=`           | `er/expand-region`                 |
| `C-:`           | `avy-goto-char`                    |
| `C-'`           | `avy-goto-char-2`                  |
| `M-g f`         | `avy-goto-line`                    |
| `M-g w`         | `avy-goto-word-1`                  |

### Multiple cursors

| Key             | Command                            |
|-----------------|------------------------------------|
| `C-S-c C-S-c`   | `mc/edit-lines`                    |
| `C->`           | `mc/mark-next-like-this`           |
| `C-<`           | `mc/mark-previous-like-this`       |
| `C-c C-<`       | `mc/mark-all-like-this`            |
| `C-c C-w`       | `mc/mark-next-like-this-word`      |
| `C-c C-s`       | `mc/mark-next-like-this-symbol`    |

### Code folding (hideshow, in `prog-mode`)

| Key       | Command              |
|-----------|----------------------|
| `C-c z a` | `hs-toggle-hiding`   |
| `C-c z c` | `hs-hide-block`      |
| `C-c z o` | `hs-show-block`      |
| `C-c z m` | `hs-hide-all`        |
| `C-c z r` | `hs-show-all`        |

---

## Completion & Search (vertico + consult + embark)

| Key       | Command                                       |
|-----------|-----------------------------------------------|
| `M-x`     | `execute-extended-command` (vertico)          |
| `C-x C-f` | `find-file` (vertico)                         |
| `C-x b`   | `consult-buffer`                              |
| `C-x p b` | `consult-project-buffer`                      |
| `C-x r b` | `consult-bookmark`                            |
| `C-x C-b` | `ibuffer`                                     |
| `M-y`     | `consult-yank-pop`                            |
| `M-g g`   | `consult-goto-line`                           |
| `M-g i`   | `consult-imenu`                               |
| `M-g I`   | `consult-imenu-multi`                         |
| `M-s d`   | `consult-fd` (find files)                     |
| `M-s g`   | `consult-ripgrep`                             |
| `M-s l`   | `consult-line`                                |
| `M-s L`   | `consult-line-multi`                          |
| `C-x C-d` | `consult-dir`                                 |
| `C-x C-j` | `consult-dir-jump-file` (inside Vertico)      |
| `C-c r`   | `consult-recent-file`                         |
| `C-c h a` | `consult-org-agenda`                          |
| `C-c h h` | `consult-org-heading`                         |
| `C-.`     | `embark-act` (act on candidate at point)      |
| `C-;`     | `embark-dwim` (default action)                |
| `C-h B`   | `embark-bindings` (browse available actions)  |

> Inside `M-s g` (ripgrep): press `C-c C-e` (via `embark-export`) to send
> results to a writable grep buffer, then `C-c C-p` (`wgrep`) to bulk-edit
> and save.

---

## Buffers & Navigation

| Key       | Command              |
|-----------|----------------------|
| `C-c b n` | `next-buffer`        |
| `C-c b p` | `previous-buffer`    |
| `C-c j t` | `beginning-of-buffer`|
| `C-c j b` | `end-of-buffer`      |
| `S-<left>`  | `windmove-left`    |
| `S-<right>` | `windmove-right`   |
| `S-<up>`    | `windmove-up`      |
| `S-<down>`  | `windmove-down`    |
| `C-c <left>`  | `winner-undo`     |
| `C-c <right>` | `winner-redo`     |

---

## Dired

| Key     | Command                  |
|---------|--------------------------|
| `C-c n` | `dired-create-empty-file`|

---

## Project (`C-c p` opens the project-prefix map)

Standard `project.el` bindings under the prefix, e.g.
`C-c p f` find file, `C-c p g` ripgrep, `C-c p d` dired,
`C-c p m` magit, `C-c p t` vterm, `C-c p k` kill buffers.

---

## Version Control

### Magit

| Key       | Command              |
|-----------|----------------------|
| `C-c m s` | `magit-status`       |
| `C-c m l` | `magit-log-current`  |

### Perforce (`C-c 4 …`)

| Key       | Command         |
|-----------|-----------------|
| `C-c 4 e` | `p4-edit`       |
| `C-c 4 a` | `p4-add`        |
| `C-c 4 d` | `p4-diff`       |
| `C-c 4 D` | `p4-diff2`      |
| `C-c 4 r` | `p4-revert`     |
| `C-c 4 s` | `p4-submit`     |
| `C-c 4 l` | `p4-filelog`    |
| `C-c 4 o` | `p4-opened`     |
| `C-c 4 S` | `p4-status`     |
| `C-c 4 m` | `p4-move`       |
| `C-c 4 c` | `p4-changes`    |
| `C-c 4 =` | `p4-describe`   |

---

## LSP — Eglot (active in code buffers)

| Key       | Command                       |
|-----------|-------------------------------|
| `C-c l a` | `eglot-code-actions`          |
| `C-c l r` | `eglot-rename`                |
| `C-c l f` | `eglot-format-buffer`         |
| `C-c l d` | `eldoc` (show docs at point)  |
| `C-c l i` | `eglot-find-implementation`   |
| `C-c l t` | `eglot-find-typeDefinition`   |
| `C-c l s` | `consult-eglot-symbols`       |
| `M-.`     | `xref-find-definitions` (default — works with eglot) |
| `M-,`     | `xref-go-back`                |
| `M-?`     | `xref-find-references`        |

### Diagnostics (Flymake)

| Key       | Command                            |
|-----------|------------------------------------|
| `C-c ! l` | `flymake-show-buffer-diagnostics`  |
| `C-c ! p` | `flymake-goto-prev-error`          |
| `C-c ! n` | `flymake-goto-next-error`          |

---

## Completion popup (corfu, in any buffer)

| Key       | Action                                |
|-----------|---------------------------------------|
| `TAB`     | Cycle / select candidate              |
| `RET`     | Insert selected                       |
| `M-SPC`   | Insert separator (orderless live filter) |
| `C-g`     | Dismiss popup                         |

---

## Org

### Global

| Key       | Command                        |
|-----------|--------------------------------|
| `C-c a`   | `org-agenda`                   |
| `C-c c`   | `org-capture`                  |
| `C-c o l` | `org-store-link`               |

### Org-Roam

| Key       | Command                              |
|-----------|--------------------------------------|
| `C-c n l` | `org-roam-buffer-toggle`             |
| `C-c n f` | `org-roam-node-find`                 |
| `C-c n i` | `org-roam-node-insert`               |
| `C-c n c` | `org-roam-capture`                   |
| `C-c n j` | `org-roam-dailies-capture-today`     |
| `C-c n s` | `my/org-roam-search-text` (ripgrep)  |

### Org Mode (buffer-local)

| Key     | Command                  |
|---------|--------------------------|
| `C-c i` | `org-download-clipboard` |

---

## Language-specific

### Emacs Lisp

| Key       | Command                            |
|-----------|------------------------------------|
| `C-c C-j` | `eval-print-last-sexp` (in `*scratch*`) |

### Lua

| Key       | Command                       |
|-----------|-------------------------------|
| `RET`     | `my/lua-newline-and-close` (auto-inserts `end`/`until`) |
| `C-c C-r` | `my/run-current-lua-file`     |

### C / C++ (and other prog modes)

| Key   | Command                |
|-------|------------------------|
| `RET` | `newline-and-indent`   |

### Markdown

Renderer is `pandoc --mathjax`, so `$$…$$` and `\(…\)` work.

| Key         | Command                          |
|-------------|----------------------------------|
| `C-c C-c p` | `markdown-preview` (browser, one-shot)            |
| `C-c C-c l` | `markdown-live-preview-mode` (eww, no JS / no math) |
| `C-c C-c x` | `markdown-xwidget-preview-mode` (in-Emacs, with MathJax) |

---

## Discoverability

| Key       | Command                                                 |
|-----------|---------------------------------------------------------|
| `C-h k`   | `helpful-key`                                           |
| `C-h f`   | `helpful-callable`                                      |
| `C-h v`   | `helpful-variable`                                      |
| `C-h x`   | `helpful-command`                                      |
| `C-c C-d` | `helpful-at-point`                                      |
| `C-h B`   | `embark-bindings` — list all actions for current target |
| *any prefix + wait 0.5s* | `which-key` shows the next-key menu      |
