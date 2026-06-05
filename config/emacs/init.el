;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

;;; Commentary:
;;
;;  1. Bootstrap                  package archives, use-package, PATH
;;  2. UI & Appearance            chrome, theme, fonts, modeline, icons,
;;                                line numbers, visual polish
;;  3. Editing                    pairs, multi-cursor, paredit, folding,
;;                                rainbow-delimiters, expand-region, avy, vundo
;;  4. Completion & Search        vertico, orderless, marginalia, consult,
;;                                embark, savehist, save-place, which-key
;;  5. File & Buffer Management   recentf, dired, ibuffer, backups, auto-revert
;;  6. Project Management         project.el
;;  7. Version Control            magit, diff-hl, wgrep, perforce
;;  8. Code Intelligence          corfu, cape, yasnippet, eglot, consult-eglot
;;  9. Language Support           tree-sitter modes + per-language packages
;; 10. Shell & Terminal           vterm, powershell, bat
;; 11. Org Mode                   core, babel, agenda, capture, roam, extras
;; 12. Markdown
;; 13. Spell Checking
;; 14. Misc Commands
;; 15. Global Keybindings
;; 16. Finalize
;;
;;; Code:


;; ============================================================
;; 1. Bootstrap
;; ============================================================

;; -- 1.1 Custom file --
(setq custom-file "~/.emacs.d/custom.el")

;; -- 1.2 Package archives --
;; Emacs has already run `package-activate-all' (from early-init's
;; `package-quickstart' setting) by the time init.el loads, so we just
;; configure archives and refresh the index if it's empty.
(require 'package)
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(unless package-archive-contents
  (package-refresh-contents))

;; -- 1.3 use-package (built-in since Emacs 29) --
(require 'use-package)
(setq use-package-always-ensure  t
      ;; When `use-package' tries to install a package whose dated tar URL is
      ;; stale (HTTP 404 from MELPA), automatically refresh the index once
      ;; and retry instead of erroring out.
      use-package-always-defer    nil)

(defun my/use-package-refresh-on-404 (orig-fn package &rest args)
  "Advice around `package-install': refresh contents once on a 404, then retry."
  (condition-case err
      (apply orig-fn package args)
    (error
     (if (and (stringp (error-message-string err))
              (string-match-p "Not found\\|404" (error-message-string err)))
         (progn
           (message "Stale MELPA index for %s — refreshing and retrying." package)
           (package-refresh-contents)
           (apply orig-fn package args))
       (signal (car err) (cdr err))))))
(advice-add 'package-install :around #'my/use-package-refresh-on-404)

;; Defer `package-quickstart-refresh' until after init completes. Emacs runs
;; it automatically after every `package-install', but it internally calls
;; `package-initialize' — which fires a spurious "Unnecessary call to
;; `package-initialize' in init file" warning when packages are installed
;; during init (typical for `use-package' :ensure on a fresh machine). Batch
;; into a single refresh after startup.
(defvar my/package-quickstart-needs-refresh nil)
(defun my/defer-quickstart-refresh ()
  "Flag a quickstart refresh instead of running it during init."
  (setq my/package-quickstart-needs-refresh t))
(advice-add 'package--quickstart-maybe-refresh
            :override #'my/defer-quickstart-refresh)
(add-hook 'emacs-startup-hook
          (lambda ()
            (advice-remove 'package--quickstart-maybe-refresh
                           #'my/defer-quickstart-refresh)
            (when my/package-quickstart-needs-refresh
              (package-quickstart-refresh))))

;; -- 1.4 PATH from shell (GUI frames on macOS/Linux) --
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :config
  (exec-path-from-shell-initialize))


;; ============================================================
;; 2. UI & Appearance
;; ============================================================

;; -- 2.1 Frame chrome (early-init also disables these to avoid flash) --
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(setq inhibit-startup-screen t
      frame-title-format '("%b  ·  Emacs")
      ring-bell-function #'ignore
      use-dialog-box nil
      use-file-dialog nil)

;; -- 2.2 Theme --
(use-package doom-themes
  :config (load-theme 'doom-tokyo-night t))

;; -- 2.3 Icons + modeline (run `M-x nerd-icons-install-fonts' once) --
(use-package nerd-icons)
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 30)
  (doom-modeline-bar-width 4)
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-buffer-state-icon t))

;; -- 2.4 Fonts (use `fc-list : family | sort -u' to view available fonts) --
(when (display-graphic-p)
  (set-face-attribute 'default nil
                      :family "IntelOne Mono"
                      :weight 'light
                      :height 135)
  (set-face-attribute 'fixed-pitch nil :family "IntelOne Mono")
  (set-face-attribute 'variable-pitch nil :family "Inter" :height 1.0))

;; -- 2.5 Line numbers (prog + text modes only) --
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)
;; Opt out of text-mode subtypes that read better without numbers.
(dolist (mode '(org-mode-hook markdown-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; -- 2.6 Pixel-precision scrolling (Emacs 29+) --
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

;; -- 2.7 Visual polish --
(global-hl-line-mode 1)
(column-number-mode 1)
(blink-cursor-mode 0)
(setq-default cursor-type 'bar)
(setq-default indicate-buffer-boundaries 'left)
(setq-default indicate-empty-lines t)
(setq window-divider-default-right-width 1
      window-divider-default-bottom-width 1)
(window-divider-mode 1)

(use-package spacious-padding
  :if (display-graphic-p)
  :init (spacious-padding-mode 1)
  :custom
  (spacious-padding-widths
   '( :internal-border-width 12
      :header-line-width 4
      :mode-line-width 6
      :tab-width 4
      :right-divider-width 8
      :scroll-bar-width 8)))

(use-package solaire-mode
  :init (solaire-global-mode 1))

(use-package pulsar
  :init (pulsar-global-mode 1)
  :custom
  (pulsar-pulse t)
  (pulsar-delay 0.045)
  (pulsar-iterations 8)
  (pulsar-face 'pulsar-cyan)
  (pulsar-highlight-face 'pulsar-cyan)
  :config
  (dolist (command '(consult-goto-line
                     consult-line
                     consult-ripgrep
                     other-window
                     recenter-top-bottom
                     switch-to-buffer
                     windmove-left
                     windmove-right
                     windmove-up
                     windmove-down
                     xref-find-definitions
                     xref-go-back))
    (add-to-list 'pulsar-pulse-functions command)))

;; -- 2.8 Indentation defaults --
(setq-default tab-width 4
              indent-tabs-mode nil)


;; ============================================================
;; 3. Editing
;; ============================================================

;; -- 3.1 Electric pairs --
(electric-pair-mode 1)
(delete-selection-mode 1)
(global-subword-mode 1)
(setq sentence-end-double-space nil
      save-interprogram-paste-before-kill t)

;; -- 3.2 Multiple cursors --
(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c C-<"     . mc/mark-all-like-this)
         ("C-c C-w"     . mc/mark-next-like-this-word)
         ("C-c C-s"     . mc/mark-next-like-this-symbol)))

;; -- 3.3 Paredit (Lisps) --
(use-package paredit
  :hook ((emacs-lisp-mode  . paredit-mode)
         (clojure-mode     . paredit-mode)
         (lisp-mode        . paredit-mode)
         (common-lisp-mode . paredit-mode)
         (scheme-mode      . paredit-mode)
         (racket-mode      . paredit-mode)))

;; -- 3.4 Rainbow delimiters --
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; -- 3.5 Expand region --
(use-package expand-region
  :bind ("C-=" . er/expand-region))

;; -- 3.6 Avy (jump to char / line / word) --
(use-package avy
  :bind (("C-:"   . avy-goto-char)
         ("C-'"   . avy-goto-char-2)
         ("M-g f" . avy-goto-line)
         ("M-g w" . avy-goto-word-1)))

;; -- 3.7 Visual undo --
(use-package vundo
  :bind ("C-x u" . vundo))

;; -- 3.8 Code folding (vim-style za/zc/zo/zm/zr) --
(use-package hideshow
  :ensure nil
  :hook (prog-mode . hs-minor-mode)
  :bind (:map hs-minor-mode-map
              ("C-c z a" . hs-toggle-hiding)
              ("C-c z c" . hs-hide-block)
              ("C-c z o" . hs-show-block)
              ("C-c z m" . hs-hide-all)
              ("C-c z r" . hs-show-all)))


;; ============================================================
;; 4. Completion & Search (vertico stack)
;; ============================================================

(use-package vertico
  :init (vertico-mode)
  :custom (vertico-cycle t))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides
   '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode))

(use-package nerd-icons-completion
  :after (marginalia nerd-icons)
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package consult
  :bind (("C-x b"   . consult-buffer)
         ("C-x p b" . consult-project-buffer)
         ("C-x r b" . consult-bookmark)
         ("M-y"     . consult-yank-pop)
         ("M-g g"   . consult-goto-line)
         ("M-g i"   . consult-imenu)
         ("M-g I"   . consult-imenu-multi)
         ("M-s d"   . consult-fd)
         ("M-s g"   . consult-ripgrep)
         ("M-s l"   . consult-line)
         ("M-s L"   . consult-line-multi)
         ("C-c r"   . consult-recent-file)
         ("C-c h a" . consult-org-agenda)
         ("C-c h h" . consult-org-heading))
  :config (setq consult-narrow-key "<"))

(use-package consult-dir
  :bind (("C-x C-d" . consult-dir)
         :map vertico-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

(use-package vertico-posframe
  :if (display-graphic-p)
  :after vertico
  :init (vertico-posframe-mode 1)
  :custom
  (vertico-posframe-border-width 1)
  (vertico-posframe-min-width 90)
  (vertico-posframe-width 110)
  (vertico-posframe-height 22)
  (vertico-posframe-poshandler #'posframe-poshandler-frame-center))

(use-package embark
  :bind (("C-."   . embark-act)
         ("C-;"   . embark-dwim)
         ("C-h B" . embark-bindings)))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; -- Built-ins --
(use-package savehist  :ensure nil :init (savehist-mode))
(use-package saveplace :ensure nil :init (save-place-mode))
(use-package which-key
  :ensure nil
  :init (which-key-mode)
  :custom (which-key-idle-delay 0.5))
(use-package autorevert
  :ensure nil
  :init (global-auto-revert-mode)
  :custom (global-auto-revert-non-file-buffers t))
(use-package repeat :ensure nil :init (repeat-mode))
(use-package windmove
  :ensure nil
  :init (windmove-default-keybindings 'shift))
(use-package winner
  :ensure nil
  :init (winner-mode 1))

(use-package helpful
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)
         ("C-c C-d" . helpful-at-point)))


;; ============================================================
;; 5. File & Buffer Management
;; ============================================================

;; -- 5.1 Recentf --
(recentf-mode 1)
(setq recentf-max-menu-items 25
      recentf-max-saved-items 100
      recentf-exclude '("/tmp/" "/.emacs.d/elpa/" "\\.gz$"))

;; -- 5.2 Dired --
(require 'dired-x)
(setq dired-omit-files "^\\.[^.]\\|^\\.\\.$"
      dired-dwim-target t)
(add-hook 'dired-mode-hook #'dired-omit-mode)
(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c n") #'dired-create-empty-file))

;; -- 5.3 Buffer navigation --
(global-set-key (kbd "C-x C-b") #'ibuffer)
(global-set-key (kbd "C-c b p") #'previous-buffer)
(global-set-key (kbd "C-c b n") #'next-buffer)
(setq uniquify-buffer-name-style 'forward)

;; -- 5.4 Backups & auto-saves --
(setq backup-directory-alist
      `(("." . ,(expand-file-name "backups/" user-emacs-directory)))
      auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-saves/" user-emacs-directory) t)))
(make-directory (expand-file-name "backups/"    user-emacs-directory) t)
(make-directory (expand-file-name "auto-saves/" user-emacs-directory) t)

;; -- 5.5 Follow symlinks into VC trees without prompting --
(setq vc-follow-symlinks t)


;; ============================================================
;; 6. Project Management
;; ============================================================

(use-package project
  :ensure nil
  :bind-keymap ("C-c p" . project-prefix-map)
  :config
  (setq project-vc-extra-root-markers
        '(".project" ".projectile" ".p4ignore" ".p4config"))
  (setq project-switch-commands
        '((project-find-file    "Find file"    "f")
          (consult-ripgrep      "Ripgrep"      "g")
          (project-dired        "Dired"        "d")
          (magit-project-status "Magit"        "m")
          (vterm                "Vterm"        "t")
          (project-kill-buffers "Kill buffers" "k"))))


;; ============================================================
;; 7. Version Control
;; ============================================================

;; -- 7.1 Magit --
(use-package magit
  :bind (("C-c m s" . magit-status)
         ("C-c m l" . magit-log-current)))

;; -- 7.2 diff-hl (magit integration is automatic in diff-hl >= 1.11) --
(use-package diff-hl
  :hook ((prog-mode  . diff-hl-mode)
         (prog-mode  . diff-hl-margin-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  (diff-hl-flydiff-mode 1))

;; -- 7.3 wgrep (edit grep results in place; C-c C-p in a grep buffer) --
(use-package wgrep
  :custom (wgrep-auto-save-buffer t))

;; -- 7.4 Perforce --
(use-package p4
  :bind (("C-c 4 e" . p4-edit)
         ("C-c 4 a" . p4-add)
         ("C-c 4 d" . p4-diff)
         ("C-c 4 D" . p4-diff2)
         ("C-c 4 r" . p4-revert)
         ("C-c 4 s" . p4-submit)
         ("C-c 4 l" . p4-filelog)
         ("C-c 4 o" . p4-opened)
         ("C-c 4 S" . p4-status)
         ("C-c 4 m" . p4-move)
         ("C-c 4 c" . p4-changes)
         ("C-c 4 =" . p4-describe)))


;; ============================================================
;; 8. Code Intelligence (eglot + corfu)
;; ============================================================

;; -- 8.1 In-buffer completion popup --
(use-package corfu
  :init (global-corfu-mode)
  :custom
  (corfu-auto              t)
  (corfu-auto-prefix       1)
  (corfu-auto-delay        0.15)
  (corfu-cycle             t)
  (corfu-quit-no-match     'separator)
  (corfu-preview-current   'insert))

(use-package corfu-popupinfo
  :ensure nil
  :after corfu
  :hook (corfu-mode . corfu-popupinfo-mode))

(use-package nerd-icons-corfu
  :after (corfu nerd-icons)
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; -- 8.2 Completion-at-point extensions --
(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;; -- 8.3 Snippets --
;; Personal snippets live in ~/.emacs.d/snippets/<mode>/ (symlinked to
;; dotfiles/config/emacs/snippets). yasnippet-snippets provides community
;; snippets for every configured language. yasnippet-capf surfaces snippet
;; keys inside the corfu popup so you don't need to remember triggers.
(use-package yasnippet
  :init (yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet)

(use-package consult-yasnippet
  :after (consult yasnippet)
  :bind ("C-c y" . consult-yasnippet))

(use-package yasnippet-capf
  :after (cape yasnippet)
  :init (add-to-list 'completion-at-point-functions #'yasnippet-capf))

;; -- 8.4 Eglot (built-in LSP client) --
(defun my/c-c++-eglot-ensure ()
  "Start Eglot for C/C++ when clangd is available."
  (if (executable-find "clangd")
      (eglot-ensure)
    (message "C/C++ LSP disabled: install clangd and reopen this buffer.")))

(defun my/eglot-format-buffer-when-managed ()
  "Format current buffer with Eglot when it is managed by a server."
  (when (eglot-managed-p)
    (eglot-format-buffer)))

(use-package eglot
  :ensure nil
  :hook ((c-mode             . my/c-c++-eglot-ensure)
         (c++-mode           . my/c-c++-eglot-ensure)
         (c-or-c++-mode      . my/c-c++-eglot-ensure)
         (c-ts-mode          . my/c-c++-eglot-ensure)
         (c++-ts-mode        . my/c-c++-eglot-ensure)
         (c-or-c++-ts-mode   . my/c-c++-eglot-ensure)
         (python-ts-mode     . eglot-ensure)
         (rust-mode          . eglot-ensure)
         (go-mode            . eglot-ensure)
         (java-ts-mode       . eglot-ensure)
         (csharp-ts-mode     . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (tsx-ts-mode        . eglot-ensure)
         (js-ts-mode         . eglot-ensure)
         (web-mode           . eglot-ensure)
         (dockerfile-mode    . eglot-ensure)
         (lua-mode           . eglot-ensure)
         (php-mode           . eglot-ensure))
  :bind (:map eglot-mode-map
              ("C-c l a" . eglot-code-actions)
              ("C-c l r" . eglot-rename)
              ("C-c l f" . eglot-format-buffer)
              ("C-c l d" . eldoc)
              ("C-c l i" . eglot-find-implementation)
              ("C-c l t" . eglot-find-typeDefinition))
  :config
  (setq eglot-events-buffer-config '(:size 0 :format full)
        eglot-autoshutdown   t
        eglot-sync-connect   0
        eglot-extend-to-xref t)
  ;; Disable jsonrpc event logging — large perf win for chatty servers.
  (fset #'jsonrpc--log-event #'ignore))

(use-package consult-eglot
  :after eglot
  :bind (:map eglot-mode-map ("C-c l s" . consult-eglot-symbols)))

;; -- 8.5 Diagnostics --
(use-package flymake
  :ensure nil
  :bind (:map flymake-mode-map
              ("C-c ! l" . flymake-show-buffer-diagnostics)
              ("C-c ! p" . flymake-goto-prev-error)
              ("C-c ! n" . flymake-goto-next-error)))


;; ============================================================
;; 9. Language Support
;; ============================================================

;; -- 9.1 Tree-sitter grammars + remaps (Emacs 29+) --
;;       Run `M-x my/install-treesit-grammars' once on a new machine.
(setq treesit-language-source-alist
      '((bash       "https://github.com/tree-sitter/tree-sitter-bash")
        (c          "https://github.com/tree-sitter/tree-sitter-c")
        (cpp        "https://github.com/tree-sitter/tree-sitter-cpp")
        (c-sharp    "https://github.com/tree-sitter/tree-sitter-c-sharp")
        (css        "https://github.com/tree-sitter/tree-sitter-css")
        (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
        (go         "https://github.com/tree-sitter/tree-sitter-go")
        (html       "https://github.com/tree-sitter/tree-sitter-html")
        (java       "https://github.com/tree-sitter/tree-sitter-java")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (json       "https://github.com/tree-sitter/tree-sitter-json")
        (python     "https://github.com/tree-sitter/tree-sitter-python")
        (rust       "https://github.com/tree-sitter/tree-sitter-rust")
        (toml       "https://github.com/tree-sitter/tree-sitter-toml")
        (tsx        "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (yaml       "https://github.com/tree-sitter-grammars/tree-sitter-yaml")))

(setq major-mode-remap-alist
      '((c-mode          . c-ts-mode)
        (c++-mode        . c++-ts-mode)
        (c-or-c++-mode   . c-or-c++-ts-mode)
        (csharp-mode     . csharp-ts-mode)
        (java-mode       . java-ts-mode)
        (javascript-mode . js-ts-mode)
        (js-mode         . js-ts-mode)
        (json-mode       . json-ts-mode)
        (python-mode     . python-ts-mode)))

(defun my/install-treesit-grammars ()
  "Install all tree-sitter grammars in `treesit-language-source-alist'."
  (interactive)
  (dolist (lang (mapcar #'car treesit-language-source-alist))
    (unless (treesit-language-available-p lang)
      (treesit-install-language-grammar lang))))

;; -- 9.2 C / C++  (requires: clangd) --
(defun my/c-ts-mode-setup ()
  "Indent, RET, and format-on-save tweaks shared by c-ts-mode/c++-ts-mode."
  (setq-local indent-tabs-mode      nil
              c-ts-mode-indent-offset 4)
  (local-set-key (kbd "RET") #'newline-and-indent)
  (add-hook 'before-save-hook #'my/eglot-format-buffer-when-managed nil t))

(setq c-ts-mode-indent-style 'k&r)
(add-hook 'c-ts-base-mode-hook #'my/c-ts-mode-setup)

;; -- 9.3 Rust  (requires: rustup component add rust-analyzer) --
(use-package rust-mode)

;; -- 9.4 Java  (requires: install eclipse-jdt-ls; eglot auto-detects it) --
;;       Eglot drives jdtls directly; lsp-java is no longer needed.

;; -- 9.5 Go  (requires: go install golang.org/x/tools/gopls@latest) --
(use-package go-mode
  :hook (go-mode . (lambda ()
                     (add-hook 'before-save-hook #'gofmt-before-save nil t))))

;; -- 9.6 PHP  (requires: composer global require intelephense, or phpactor) --
(use-package php-mode)

;; -- 9.7 C#  (requires: dotnet tool install -g csharp-ls) --
;;       csharp-mode + csharp-ts-mode are built-in in Emacs 29+.

;; -- 9.8 Lua  (requires: brew install lua-language-server) --
(defun my/run-current-lua-file ()
  "Run the current Lua file with `lua'."
  (interactive)
  (when (buffer-file-name)
    (save-buffer)
    (compile (format "lua %s"
                     (shell-quote-argument
                      (file-name-nondirectory buffer-file-name))))))

(use-package lua-mode
  :mode "\\.lua\\'"
  :config (setq lua-indent-level 2)
  :bind (:map lua-mode-map
              ("C-c C-r" . my/run-current-lua-file)))

(defun my/lua-newline-and-close ()
  "Newline-and-indent; insert matching end/until after Lua block openers."
  (interactive)
  (let* ((line (string-trim
                (buffer-substring-no-properties
                 (line-beginning-position) (point))))
         (closer (cond
                  ((string-match-p "\\`\\(local +\\)?function\\b" line)   "end")
                  ((string-match-p "\\(if\\|elseif\\).*\\bthen\\'"  line) "end")
                  ((string-match-p "\\(for\\|while\\).*\\bdo\\'"    line) "end")
                  ((string-match-p "\\`do\\'"                       line) "end")
                  ((string-match-p "\\`repeat\\'"                   line) "until ")
                  (t nil))))
    (newline-and-indent)
    (when closer
      (save-excursion
        (newline)
        (insert closer)
        (indent-according-to-mode)))))

(add-hook 'lua-mode-hook
          (lambda ()
            (local-set-key (kbd "RET") #'my/lua-newline-and-close)))

;; -- 9.9 Python  (requires: pip install pyright  or  python-lsp-server[all]) --
;;       Eglot-ensure is registered on python-ts-mode above.

;; -- 9.10 TypeScript / JavaScript (web dev) --
;;        requires: npm i -g typescript typescript-language-server
(add-to-list 'auto-mode-alist '("\\.ts\\'"  . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))

;; HTML / CSS / templates
(use-package web-mode
  :mode (("\\.html?\\'"  . web-mode)
         ("\\.css\\'"    . web-mode)
         ("\\.s[ac]ss\\'" . web-mode))
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset    2
        web-mode-code-indent-offset   2))

;; -- 9.11 Emacs Lisp --
(with-eval-after-load 'elisp-mode
  (define-key lisp-interaction-mode-map (kbd "C-c C-j")
              #'eval-print-last-sexp))

;; -- 9.12 Dockerfile  (requires: npm i -g dockerfile-language-server-nodejs) --
(use-package dockerfile-mode)

;; -- 9.13 PowerShell / Batch --
(use-package powershell)
(use-package bat-mode
  :ensure nil
  :mode (("\\.bat\\'" . bat-mode)
         ("\\.cmd\\'" . bat-mode)))


;; ============================================================
;; 10. Shell & Terminal
;; ============================================================

(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))


;; ============================================================
;; 11. Org Mode
;; ============================================================

(setq org-directory             "~/Zettelkasten/Org"
      my/org-agenda-directory   (expand-file-name "agenda" "~/Zettelkasten/Org"))

(unless (file-directory-p my/org-agenda-directory)
  (make-directory my/org-agenda-directory t))

;; -- 11.1 Core --
(use-package org
  :ensure nil
  :mode ("\\.org\\'" . org-mode)
  :config
  ;; sudo tlmgr install dvisvgm
  (setq org-preview-latex-default-process 'dvisvgm
        org-confirm-babel-evaluate        nil
        org-src-fontify-natively          t
        org-log-done                      'time
        org-highest-priority              ?A
        org-default-priority              ?B
        org-lowest-priority               ?C)
  (setq org-format-latex-options
        (plist-put org-format-latex-options :scale 1.5))
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "DOING(g)" "WAIT(w@/!)" "MEETING(m)"
                    "|" "DONE(d!)" "CANCELLED(c@)")))
  (setq org-todo-keyword-faces
        '(("TODO"      . (:weight bold))
          ("NEXT"      . (:weight bold))
          ("DOING"     . (:weight bold))
          ("WAIT"      . (:weight bold))
          ("MEETING"   . (:weight bold))
          ("CANCELLED" . (:weight bold))))
  (setq org-tag-alist
        '((:startgroup)
          ("work"     . ?w)
          ("study"    . ?s)
          ("research" . ?r)
          ("personal" . ?p)
          (:endgroup)
          ("meeting"  . ?m)
          ("email"    . ?e)
          ("call"     . ?c)
          ("urgent"   . ?u)
          ("waiting"  . ?W))))

(add-hook 'org-mode-hook
          (lambda ()
            (visual-line-mode 1)
            (org-indent-mode 1)
            ;; Skip org links, URLs, and file paths during spell-check
            (make-local-variable 'ispell-skip-region-alist)
            (add-to-list 'ispell-skip-region-alist '("\\[\\[" . "\\]\\]"))
            (add-to-list 'ispell-skip-region-alist '("https?://" . "\\S-*"))
            (add-to-list 'ispell-skip-region-alist '("[./\\~][-a-zA-Z0-9_./\\]*"))
            ;; Don't auto-pair <>; org uses < for template expansion
            (setq-local electric-pair-pairs
                        (seq-remove (lambda (p) (= (car p) ?<))
                                    electric-pair-pairs))
            (setq-local electric-pair-text-pairs
                        (seq-remove (lambda (p) (= (car p) ?<))
                                    electric-pair-text-pairs))
            (add-hook 'post-self-insert-hook
                      (lambda ()
                        (when (and (eq last-command-event ?<)
                                   (eq (char-after) ?>))
                          (delete-char 1)))
                      nil t)))

(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode))

;; -- 11.2 Babel --
(with-eval-after-load 'org
  (require 'ob-C)
  (defalias 'org-babel-execute:c   'org-babel-execute:C)
  (defalias 'org-babel-execute:c++ 'org-babel-execute:C++)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((lua        . t)
     (emacs-lisp . t)
     (C          . t)
     (java       . t))))

(setq org-babel-default-header-args:lua '((:results . "output"))
      org-babel-default-header-args:java
      `((:dir     . ,(temporary-file-directory))
        (:results . "output")))

(use-package ob-php
  :after org
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   (append org-babel-load-languages '((php . t)))))

;; -- 11.3 Agenda & Capture --
(setq org-agenda-files
      (list (expand-file-name "inbox.org"    my/org-agenda-directory)
            (expand-file-name "tasks.org"    my/org-agenda-directory)
            (expand-file-name "meetings.org" my/org-agenda-directory)
            (expand-file-name "projects.org" my/org-agenda-directory)
            (expand-file-name "someday.org"  my/org-agenda-directory)))

(setq org-agenda-span                   7
      org-agenda-start-on-weekday       nil
      org-agenda-window-setup           'current-window
      org-agenda-show-future-repeats    t
      org-agenda-skip-deadline-if-done  t
      org-agenda-skip-scheduled-if-done t)

(setq org-capture-templates
      `(("t" "Task" entry
         (file+headline ,(expand-file-name "tasks.org" my/org-agenda-directory) "Tasks")
         "* TODO %?\n  CREATED: %U\n  %a\n")
        ("i" "Inbox" entry
         (file+headline ,(expand-file-name "inbox.org" my/org-agenda-directory) "Inbox")
         "* TODO %?\n  CREATED: %U\n  %a\n")
        ("m" "Meeting" entry
         (file+headline ,(expand-file-name "meetings.org" my/org-agenda-directory) "Meetings")
         "* MEETING %? :meeting:\nSCHEDULED: %^T\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n** Attendees\n- \n\n** Agenda\n- \n\n** Notes\n- \n\n** Decisions\n- \n\n** Action Items\n- [ ] \n")
        ("p" "Project task" entry
         (file+headline ,(expand-file-name "projects.org" my/org-agenda-directory) "Project Tasks")
         "* TODO %? :work:\n  CREATED: %U\n  %a\n")
        ("s" "Someday" entry
         (file+headline ,(expand-file-name "someday.org" my/org-agenda-directory) "Someday")
         "* TODO %?\n  CREATED: %U\n")))

;; -- 11.4 Roam --
(use-package org-roam
  :custom (org-roam-directory "~/Zettelkasten/Org")
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ("C-c n j" . org-roam-dailies-capture-today))
  :config (org-roam-db-autosync-mode))

(defun my/org-roam-search-text ()
  "Full-text search in `org-roam-directory' via consult-ripgrep."
  (interactive)
  (require 'org-roam)
  (consult-ripgrep org-roam-directory))

;; -- 11.5 Extras --
(use-package org-download
  :after org
  :config
  (setq org-download-image-dir             "./images"
        org-download-method                'directory
        org-download-display-inline-images t)
  :bind (:map org-mode-map ("C-c i" . org-download-clipboard)))

(use-package org-modern
  :hook (org-mode . org-modern-mode)
  :config (setq org-modern-table-vertical nil))


;; ============================================================
;; 12. Markdown
;; ============================================================

(global-so-long-mode 1)

(defun my/markdown-big-file-lite-mode ()
  "Disable expensive minor modes when the buffer is over 1 MB."
  (when (> (buffer-size) (* 1 1024 1024))
    (font-lock-mode -1)
    (visual-line-mode -1)
    (flyspell-mode -1)
    (when (bound-and-true-p flymake-mode) (flymake-mode -1))
    (message "Big Markdown file detected: using lightweight editing mode.")))

(defun my/markdown-setup ()
  "Disable line numbers and force LTR in Markdown buffers."
  (display-line-numbers-mode -1)
  (setq-local bidi-display-reordering  nil)
  (setq-local bidi-paragraph-direction 'left-to-right)
  (my/markdown-big-file-lite-mode))

(use-package markdown-mode
  :mode (("\\.md\\'"       . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :hook (markdown-mode . my/markdown-setup))


;; ============================================================
;; 13. Spell Checking
;; ============================================================

(use-package flyspell
  :ensure nil
  :hook ((org-mode  . flyspell-mode)
         (text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode))
  :config
  (setq ispell-program-name "hunspell"
        ispell-dictionary   "en_US"))


;; ============================================================
;; 14. Misc Commands
;; ============================================================
;; (See `my/run-current-lua-file' in section 9.8 and helpers in section 12.)

(defun my/back-to-indentation-if-any ()
  "Jump to the first non-blank character of the current line.
Do nothing when the line contains only whitespace."
  (interactive)
  (let ((origin (point)))
    (back-to-indentation)
    (when (eolp)
      (goto-char origin))))


;; ============================================================
;; 15. Global Keybindings
;; ============================================================

(global-set-key (kbd "C-x ,")   #'duplicate-dwim)      ; built-in (Emacs 29+)
(global-set-key (kbd "C-x r")   #'undo-redo)
(global-set-key (kbd "C-c j t") #'beginning-of-buffer)
(global-set-key (kbd "C-c j b") #'end-of-buffer)
(global-set-key (kbd "C-c 0")   #'my/back-to-indentation-if-any)

;; Org global commands (note: org-store-link moved off C-c l to avoid
;; collision with eglot keymap prefix)
(global-set-key (kbd "C-c a")   #'org-agenda)
(global-set-key (kbd "C-c c")   #'org-capture)
(global-set-key (kbd "C-c o l") #'org-store-link)
(global-set-key (kbd "C-c n s") #'my/org-roam-search-text)


;; ============================================================
;; 16. Finalize
;; ============================================================

(when (file-exists-p custom-file)
  (load-file custom-file))

;;; init.el ends here
