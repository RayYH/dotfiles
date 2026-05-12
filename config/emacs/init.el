(use-package exec-path-from-shell
  :ensure t
  :if (memq window-system '(mac ns x))
  :config
  (exec-path-from-shell-initialize))

(setq custom-file "~/.emacs.d/custom.el")

(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)

(setq inhibit-startup-screen t)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'doom-themes)
  (package-install 'doom-themes))

(load-theme 'doom-tokyo-night t)

(package-install-selected-packages t)

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

(dolist (mode '(term-mode-hook
		shell-mode-hook
		eshell-mode-hook
		org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(when (display-graphic-p)
  (set-face-attribute 'default nil :family "IntelOne Mono" :height 120))

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

;; Buffer switching without arrow keys
(global-set-key (kbd "C-c b p") #'previous-buffer)
(global-set-key (kbd "C-c b n") #'next-buffer)

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
