(setq custom-file "~/.emacs.d/custom.el")

(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)

(setq inhibit-startup-screen t)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/") t)
(package-initialize)

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
  ;; Optional: increase scrollback
  (setq vterm-max-scrollback 10000))

;; (use-package org-roam
;;   :ensure t
;;   :custom
;;   (org-roam-directory "~/Zettelkasten/Org")
;;   :bind (("C-c n l" . org-roam-buffer-toggle)
;;          ("C-c n f" . org-roam-node-find)
;;          ("C-c n i" . org-roam-node-insert)
;;          ("C-c n c" . org-roam-capture)
;;          ("C-c n j" . org-roam-dailies-capture-today))
;;   :config
;;   (org-roam-db-autosync-mode))

;; Always follow symbolic links to version-controlled files.
(setq vc-follow-symlinks t)

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

(use-package diff-hl
  :ensure t
  :hook ((prog-mode . diff-hl-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)))

(load-file custom-file)
