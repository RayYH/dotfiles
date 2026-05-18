(setq custom-file "~/.emacs.d/custom.el")
(require 'package)
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

(package-initialize)

(unless (package-installed-p 'use-package)
  (unless package-archive-contents
    (package-refresh-contents))
  (package-install 'use-package))
(require 'use-package)

(setq use-package-always-ensure t)

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :config
  (exec-path-from-shell-initialize))

(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)

(setq inhibit-startup-screen t)

(unless (package-installed-p 'doom-themes)
     (package-install 'doom-themes))

(load-theme 'doom-tokyo-night t)

(package-install-selected-packages t)

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

(electric-pair-mode 1)

(dolist (mode '(term-mode-hook
		shell-mode-hook
		eshell-mode-hook
		org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(when (display-graphic-p)
  (set-face-attribute 'default nil :family "IntelOne Mono" :height 150))

(use-package vterm
  :ensure t
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))

(use-package powershell
  :ensure t)

(use-package bat-mode
  :ensure t
  :mode (("\\.bat\\'" . bat-mode)
         ("\\.cmd\\'" . bat-mode)))

(use-package ob-php
  :ensure t
  :after org
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   (append org-babel-load-languages
           '((php . t)))))

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory "~/Zettelkasten/Org")
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ("C-c n j" . org-roam-dailies-capture-today))
  :config
  (org-roam-db-autosync-mode))

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

(add-hook 'org-mode-hook
          (lambda ()
            (visual-line-mode 1)
            (org-indent-mode 1)))

(defun my/org-roam-search-text ()
  "Search full text in org-roam-directory using ripgrep via helm."
  (interactive)
  (require 'org-roam)
  (let ((default-directory org-roam-directory)
        (helm-grep-ag-command
         "rg --color=always --smart-case --no-heading --line-number %s %s %s"))
    (helm-do-grep-ag nil)))

(global-set-key (kbd "C-c n s") #'my/org-roam-search-text)

(use-package org-download
  :ensure t
  :after org
  :config
  ;; Save images into ./images relative to current Org file
  (setq org-download-image-dir "./images")
  ;; Insert image link at point
  (setq org-download-method 'directory)
  ;; Automatically display the image after insertion
  (setq org-download-display-inline-images t)
  ;; Optional convenient keybinding
  (define-key org-mode-map (kbd "C-c i") #'org-download-clipboard))

(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode))

(recentf-mode 1)
(setq recentf-max-menu-items 25
      recentf-max-saved-items 100
      recentf-exclude '("/tmp/" "/.emacs.d/elpa/" "\\.gz$"))

;; Always follow symbolic links to version-controlled files.
(setq vc-follow-symlinks t)

(use-package smex
  :ensure t
  :bind (("M-x" . smex)
         ("C-c C-c M-x" . execute-extended-command)))

(use-package ido-completing-read+
  :ensure t
  :config
  (ido-mode 1)
  (ido-everywhere 1)
  (ido-ubiquitous-mode 1)
  (setq ido-enable-flex-matching t))

(use-package helm
  :ensure t
  :config
  (setq helm-ff-transformer-show-only-basename nil))

(global-set-key (kbd "C-c h g g") 'helm-grep-do-git-grep)

(use-package helm-ls-git
  :ensure t
  :bind ("C-c h g l" . helm-ls-git-ls))

(global-set-key (kbd "C-c h f") 'helm-find)
(global-set-key (kbd "C-c h a") 'helm-org-agenda-files-headings)
(global-set-key (kbd "C-c h r") 'helm-recentf)

(require 'dired-x)
(setq dired-omit-files "^\\.[^.]\\|^\\.\\.$"
      dired-dwim-target t)
(add-hook 'dired-mode-hook #'dired-omit-mode)

(use-package paredit
  :ensure t
  :hook ((emacs-lisp-mode  . paredit-mode)
         (clojure-mode     . paredit-mode)
         (lisp-mode        . paredit-mode)
         (common-lisp-mode . paredit-mode)
         (scheme-mode      . paredit-mode)
         (racket-mode      . paredit-mode)))

(use-package magit
  :ensure t
  :bind (("C-c m s" . magit-status)
         ("C-c m l" . magit-log-current)))

(use-package project
  :config
  (setq project-vc-extra-root-markers '(".project" ".projectile" ".p4ignore" ".p4config"))
  (setq project-switch-commands
        '((project-find-file    "Find file"    "f")
          (project-find-regexp  "Find regexp"  "g")
          (project-dired        "Dired"        "d")
          (magit-project-status "Magit"        "m")
          (vterm                "Vterm"        "t")
          (project-kill-buffers "Kill buffers" "k")))
  :bind-keymap ("C-c p" . project-prefix-map))

(use-package yasnippet
  :ensure t
  :hook (lsp-mode . yas-minor-mode))

(use-package lsp-mode
  :ensure t
  :hook ((java-mode       . lsp-deferred)
         (rust-mode       . lsp-deferred)
         (go-mode         . lsp-deferred)
         (typescript-mode . lsp-deferred)
         (js-mode         . lsp-deferred)
         (python-mode     . lsp-deferred)
         (c-mode          . lsp-deferred)
         (c++-mode        . lsp-deferred))
  :commands (lsp lsp-deferred)
  :config
  (setq lsp-keymap-prefix "C-c l"
        lsp-idle-delay 0.5
        lsp-lens-enable t))

(use-package lsp-ui
  :ensure t
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-doc-enable t
        lsp-ui-sideline-enable t
        lsp-ui-peek-enable t))

(use-package company
  :ensure t
  :hook (prog-mode . company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.2))

(use-package helm-lsp
  :ensure t
  :after (lsp-mode helm)
  :commands helm-lsp-workspace-symbol)

;; Java — lsp-java auto-downloads Eclipse JDT LS
(use-package lsp-java
  :ensure t
  :after lsp-mode)

;; Rust
(use-package rust-mode
  :ensure t)

;; Go — auto-format on save; requires: go install golang.org/x/tools/gopls@latest
(use-package go-mode
  :ensure t
  :hook (go-mode . (lambda ()
                     (add-hook 'before-save-hook #'gofmt-before-save nil t))))

;; TypeScript/TSX — requires: npm i -g typescript-language-server typescript
(use-package typescript-mode
  :ensure t
  :mode "\\.tsx?\\'")

;; Python uses built-in python-mode; requires: pip install pyright
;; C/C++ uses built-in modes; requires: clangd (via system package manager)

;; Dockerfile — requires: npm i -g dockerfile-language-server-nodejs
(use-package dockerfile-mode
  :ensure t
  :hook (dockerfile-mode . lsp-deferred))

(use-package p4
  :ensure t
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

(use-package diff-hl
  :ensure t
  :hook ((prog-mode . diff-hl-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)))

(global-set-key (kbd "C-x r") #'undo-redo)

;; Buffer switching without arrow keys
(global-set-key (kbd "C-c b p") #'previous-buffer)
(global-set-key (kbd "C-c b n") #'next-buffer)

;; Spell checking
(use-package flyspell
  :ensure nil
  :hook ((org-mode . flyspell-mode)
         (text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode))
  :config
  (setq ispell-program-name "hunspell")
  (setq ispell-dictionary "en_US"))

;; org babel
(with-eval-after-load 'org
  (require 'ob-C)
  (defalias 'org-babel-execute:c++ 'org-babel-execute:C++)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((lua . t)
     (emacs-lisp . t)
     (C . t))))

(setq org-confirm-babel-evaluate nil)
(setq org-babel-default-header-args:lua
      '((:results . "output")))


(defun my/duplicate-line ()
  "Duplicate current line, leaving point on the new copy at the same column."
  (interactive)
  (let ((col (current-column))
        (line (buffer-substring (line-beginning-position) (line-end-position))))
    (end-of-line)
    (newline)
    (insert line)
    (move-to-column col)))

(global-set-key (kbd "C-,") #'my/duplicate-line)

(load-file custom-file)
