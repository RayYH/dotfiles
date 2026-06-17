# Emacs Keymap Quick Reference

Keys defined in `init.el`. Default Emacs bindings not listed unless overridden.
`which-key` is already on — press any prefix and wait 0.5s to see the live
menu.

This config supports **both Emacs-native keys and Vim (evil) keys**. Evil is
on by default:

- `C-c t v` (or `SPC t v`) toggles evil-mode globally.
- `C-z` drops just the current buffer into emacs-state (one-off escape hatch).
- All `C-c …` / `C-x …` bindings below work in *every* evil state.
- A `SPC` leader (normal/visual/motion state) mirrors the most-used `C-c`
  commands — see [SPC Leader Map](#spc-leader-map-evil-normalvisualmotion).

## Prefix Map

### Emacs-side (always active)

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
| `C-c t`   | Toggles (`C-c t v` = evil-mode)     |
| `C-c z`   | Code folding (hideshow)             |
| `C-c 4`   | Perforce                            |
| `C-c C-`  | Multiple cursors / mode-local       |

### Evil-side (`SPC` in normal/visual/motion state)

| Prefix    | Domain                              |
|-----------|-------------------------------------|
| `SPC f`   | Files                               |
| `SPC b`   | Buffers                             |
| `SPC w`   | Windows                             |
| `SPC p`   | Project                             |
| `SPC s`   | Search / jump                       |
| `SPC g`   | Git / VCS (magit)                   |
| `SPC l`   | LSP (eglot)                         |
| `SPC e`   | Errors (flymake)                    |
| `SPC o`   | Org                                 |
| `SPC n`   | Notes (org-roam)                    |
| `SPC t`   | Toggles                             |
| `SPC h`   | Help                                |
| `SPC q`   | Quit                                |

---

## Evil (Vim emulation)

Evil is enabled at startup. Terminals/REPLs open in **insert state**
(`vterm`, `eshell`, `shell`, `term`, `comint`, `inferior-python`,
`inferior-emacs-lisp`); help/info/messages buffers open in **normal state**.
The minibuffer is left as-is so vertico/consult bindings (`C-n`, `M-RET`,
etc.) keep working.

### Tweaks vs. stock evil

| Setting                          | Effect                                                                 |
|----------------------------------|------------------------------------------------------------------------|
| `evil-want-C-u-scroll`           | `C-u` = vim half-page up (use `C-M-u` for `universal-argument`)        |
| `evil-want-C-i-jump nil`         | TAB keeps its Emacs meaning (org cycle, magit section, etc.)           |
| `evil-want-Y-yank-to-eol`        | `Y` yanks to end of line (Vim default, not legacy vi)                  |
| `evil-undo-system 'undo-redo`    | `u` / `C-r` use Emacs 28+ built-in undo-redo; plays well with `vundo`  |
| `evil-symbol-word-search`        | `*` / `#` match symbols (foo-bar) not just words                       |
| `evil-respect-visual-line-mode`  | `j`/`k` walk visual lines when `visual-line-mode` is on                |

### Plugins

| Plugin            | Sample                       | What it does                                  |
|-------------------|------------------------------|-----------------------------------------------|
| `evil-collection` | (passive)                    | Vim bindings for magit, dired, ibuffer, …     |
| `evil-surround`   | `ysiw"` / `cs"'` / `ds(`     | Add / change / delete surrounding pairs       |
| `evil-commentary` | `gcc` / `gcip` / `gc<motion>`| Toggle comments via Emacs comment commands    |
| `evil-snipe`      | `s ab` / `S ab` / `;` / `,`  | Two-character `f`/`t` jump with highlight     |

### Toggling

| Key             | Effect                                                       |
|-----------------|--------------------------------------------------------------|
| `C-c t v`       | Toggle `evil-mode` globally                                  |
| `SPC t v`       | Same, from normal state                                      |
| `C-z`           | Flip current buffer into emacs-state (still inside evil)     |
| `ESC`           | Exit insert/visual → normal state                            |
| `C-M-u`         | `universal-argument` (since `C-u` is taken by vim scroll)    |

---

## SPC Leader Map (evil normal/visual/motion)

### Top-level

| Key       | Command                       |
|-----------|-------------------------------|
| `SPC SPC` | `execute-extended-command`    |
| `SPC x`   | `execute-extended-command`    |
| `SPC .`   | `find-file`                   |
| `SPC ,`   | `consult-buffer`              |
| `SPC ;`   | `eval-expression`             |
| `SPC TAB` | `mode-line-other-buffer` (alternate buffer) |
| `SPC /`   | `consult-ripgrep` (project search)          |
| `SPC u`   | `universal-argument`          |

### `SPC f` — files

| Key       | Command                       |
|-----------|-------------------------------|
| `SPC f f` | `find-file`                   |
| `SPC f s` | `save-buffer`                 |
| `SPC f S` | `write-file` (save as)        |
| `SPC f r` | `consult-recent-file`         |
| `SPC f d` | `consult-dir`                 |
| `SPC f y` | Copy current file path to kill-ring |

### `SPC b` — buffers

| Key       | Command                |
|-----------|------------------------|
| `SPC b b` | `consult-buffer`       |
| `SPC b k` | `kill-current-buffer`  |
| `SPC b K` | `kill-buffer` (prompt) |
| `SPC b n` | `next-buffer`          |
| `SPC b p` | `previous-buffer`      |
| `SPC b r` | `revert-buffer`        |
| `SPC b i` | `ibuffer`              |
| `SPC b s` | `scratch-buffer`       |

### `SPC w` — windows

| Key       | Command                |
|-----------|------------------------|
| `SPC w h` | `windmove-left`        |
| `SPC w j` | `windmove-down`        |
| `SPC w k` | `windmove-up`          |
| `SPC w l` | `windmove-right`       |
| `SPC w s` | `split-window-below`   |
| `SPC w v` | `split-window-right`   |
| `SPC w d` | `delete-window`        |
| `SPC w o` | `delete-other-windows` |
| `SPC w =` | `balance-windows`      |
| `SPC w m` | `maximize-window`      |

### `SPC p` — project

| Key       | Command                 |
|-----------|-------------------------|
| `SPC p p` | `project-switch-project`|
| `SPC p f` | `project-find-file`     |
| `SPC p d` | `project-find-dir`      |
| `SPC p b` | `consult-project-buffer`|
| `SPC p k` | `project-kill-buffers`  |
| `SPC p s` | `consult-ripgrep`       |
| `SPC p c` | `project-compile`       |
| `SPC p !` | `project-shell-command` |

### `SPC s` — search / jump

| Key       | Command                |
|-----------|------------------------|
| `SPC s s` | `consult-line`         |
| `SPC s S` | `consult-line-multi`   |
| `SPC s i` | `consult-imenu`        |
| `SPC s I` | `consult-imenu-multi`  |
| `SPC s g` | `consult-ripgrep`      |
| `SPC s f` | `consult-fd`           |
| `SPC s j` | `avy-goto-char-2`      |
| `SPC s l` | `avy-goto-line`        |

### `SPC g` — git

| Key       | Command                  |
|-----------|--------------------------|
| `SPC g g` | `magit-status`           |
| `SPC g b` | `magit-blame`            |
| `SPC g l` | `magit-log-buffer-file`  |
| `SPC g d` | `magit-diff-buffer-file` |
| `SPC g B` | `magit-branch-checkout`  |

### `SPC l` — LSP (eglot)

| Key       | Command                       |
|-----------|-------------------------------|
| `SPC l a` | `eglot-code-actions`          |
| `SPC l r` | `eglot-rename`                |
| `SPC l f` | `eglot-format-buffer`         |
| `SPC l d` | `eldoc`                       |
| `SPC l i` | `eglot-find-implementation`   |
| `SPC l t` | `eglot-find-typeDefinition`   |
| `SPC l s` | `consult-eglot-symbols`       |

### `SPC e` — errors (flymake)

| Key       | Command                            |
|-----------|------------------------------------|
| `SPC e l` | `flymake-show-buffer-diagnostics`  |
| `SPC e n` | `flymake-goto-next-error`          |
| `SPC e p` | `flymake-goto-prev-error`          |

### `SPC o` — org

| Key       | Command          |
|-----------|------------------|
| `SPC o a` | `org-agenda`     |
| `SPC o c` | `org-capture`    |
| `SPC o l` | `org-store-link` |
| `SPC o t` | `org-todo-list`  |

### `SPC n` — notes (org-roam)

| Key       | Command                  |
|-----------|--------------------------|
| `SPC n l` | `org-roam-buffer-toggle` |
| `SPC n f` | `org-roam-node-find`     |
| `SPC n i` | `org-roam-node-insert`   |
| `SPC n s` | `my/org-roam-search-text`|

### `SPC t` — toggles

| Key       | Command                    |
|-----------|----------------------------|
| `SPC t v` | `evil-mode`                |
| `SPC t l` | `display-line-numbers-mode`|
| `SPC t w` | `visual-line-mode`         |
| `SPC t s` | `flyspell-mode`            |
| `SPC t t` | `consult-theme`            |

### `SPC h` — help

| Key       | Command            |
|-----------|--------------------|
| `SPC h f` | `helpful-callable` |
| `SPC h v` | `helpful-variable` |
| `SPC h k` | `helpful-key`      |
| `SPC h m` | `describe-mode`    |
| `SPC h b` | `embark-bindings`  |

### `SPC q` — quit

| Key       | Command                       |
|-----------|-------------------------------|
| `SPC q q` | `save-buffers-kill-terminal`  |
| `SPC q r` | `restart-emacs` (requires the `restart-emacs` package) |

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
