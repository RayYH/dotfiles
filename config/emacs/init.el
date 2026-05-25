;;; init.el --- Emacs configuration


;; ============================================================
;; Bootstrap: package manager & use-package
;; ============================================================

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

;; Sync PATH from shell on macOS/Linux GUI frames
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :config
  (exec-path-from-shell-initialize))


;; ============================================================
;; UI & Appearance
;; ============================================================

(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(setq inhibit-startup-screen t)

(unless (package-installed-p 'doom-themes)
  (package-install 'doom-themes))
(load-theme 'doom-tokyo-night t)

(when (display-graphic-p)
  (set-face-attribute 'default nil :family "IntelOne Mono" :height 150))

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(dolist (mode '(term-mode-hook shell-mode-hook eshell-mode-hook org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))


;; ============================================================
;; Editing Fundamentals
;; ============================================================

(electric-pair-mode 1)

(use-package paredit
  :hook ((emacs-lisp-mode  . paredit-mode)
         (clojure-mode     . paredit-mode)
         (lisp-mode        . paredit-mode)
         (common-lisp-mode . paredit-mode)
         (scheme-mode      . paredit-mode)
         (racket-mode      . paredit-mode)))

(global-set-key (kbd "C-x r") #'undo-redo)

(defun my/duplicate-line ()
  "Duplicate current line, leaving point on the new copy at the same column."
  (interactive)
  (let ((col (current-column))
        (line (buffer-substring (line-beginning-position) (line-end-position))))
    (end-of-line)
    (newline)
    (insert line)
    (move-to-column col)))
(global-set-key (kbd "C-x ,") #'my/duplicate-line)


;; ============================================================
;; Completion & Search
;; ============================================================

(use-package smex
  :bind (("M-x"           . smex)
         ("C-c C-c M-x"   . execute-extended-command)))

(use-package ido-completing-read+
  :config
  (ido-mode 1)
  (ido-everywhere 1)
  (ido-ubiquitous-mode 1)
  (setq ido-enable-flex-matching t))

(use-package helm
  :config
  (setq helm-ff-transformer-show-only-basename nil))

(use-package helm-ls-git
  :bind ("C-c h g l" . helm-ls-git-ls))

(global-set-key (kbd "C-c h g g") 'helm-grep-do-git-grep)
(global-set-key (kbd "C-c h f")   'helm-find)
(global-set-key (kbd "C-c h a")   'helm-org-agenda-files-headings)
(global-set-key (kbd "C-c h r")   'helm-recentf)


;; ============================================================
;; File & Buffer Management
;; ============================================================

(recentf-mode 1)
(setq recentf-max-menu-items 25
      recentf-max-saved-items 100
      recentf-exclude '("/tmp/" "/.emacs.d/elpa/" "\\.gz$"))

(setq vc-follow-symlinks t)

(require 'dired-x)
(setq dired-omit-files "^\\.[^.]\\|^\\.\\.$"
      dired-dwim-target t)
(add-hook 'dired-mode-hook #'dired-omit-mode)

(global-set-key (kbd "C-x C-b") #'ibuffer)
(global-set-key (kbd "C-c b p") #'previous-buffer)
(global-set-key (kbd "C-c b n") #'next-buffer)


;; ============================================================
;; Version Control
;; ============================================================

(use-package magit
  :bind (("C-c m s" . magit-status)
         ("C-c m l" . magit-log-current)))

(use-package diff-hl
  :hook ((prog-mode          . diff-hl-mode)
         (magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)))

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
;; Project Management
;; ============================================================

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


;; ============================================================
;; LSP & Language Support
;; ============================================================

(use-package yasnippet
  :hook (lsp-mode . yas-minor-mode))

(use-package lsp-mode
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
  (setq lsp-keymap-prefix                  "C-c l"
        lsp-idle-delay                     0.5
        lsp-lens-enable                    t
        lsp-headerline-breadcrumb-enable   nil))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-doc-enable     t
        lsp-ui-sideline-enable t
        lsp-ui-peek-enable     t))

(use-package company
  :hook (prog-mode . company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.2))

(use-package helm-lsp
  :after (lsp-mode helm)
  :commands helm-lsp-workspace-symbol)

;; Java — lsp-java auto-downloads Eclipse JDT LS
(use-package lsp-java
  :after lsp-mode)

(use-package rust-mode)

;; Go — requires: go install golang.org/x/tools/gopls@latest
(use-package go-mode
  :hook (go-mode . (lambda ()
                     (add-hook 'before-save-hook #'gofmt-before-save nil t))))

;; TypeScript/TSX — requires: npm i -g typescript-language-server typescript
(use-package typescript-mode
  :mode "\\.tsx?\\'")

;; Python uses built-in python-mode; requires: pip install pyright
;; C/C++ uses built-in modes; requires: clangd

;; Dockerfile — requires: npm i -g dockerfile-language-server-nodejs
(use-package dockerfile-mode
  :hook (dockerfile-mode . lsp-deferred))


;; ============================================================
;; Shell & Terminal
;; ============================================================

(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))

(use-package powershell)

(use-package bat-mode
  :mode (("\\.bat\\'" . bat-mode)
         ("\\.cmd\\'" . bat-mode)))


;; ============================================================
;; Org Mode
;; ============================================================

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

(setq org-directory "~/Zettelkasten/Org")
(setq my/org-agenda-directory (expand-file-name "agenda" org-directory))
(unless (file-directory-p my/org-agenda-directory)
  (make-directory my/org-agenda-directory t))

;; -- Core --

(use-package org
  :config
  ;; sudo tlmgr install dvisvgm
  (setq org-preview-latex-default-process 'dvisvgm)
  (setq org-format-latex-options
        (plist-put org-format-latex-options :scale 1.5)))

(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode))

(add-hook 'org-mode-hook
          (lambda ()
            (visual-line-mode 1)
            (org-indent-mode 1)
            ;; Skip org links, URLs, and file paths during spell-check
            (make-local-variable 'ispell-skip-region-alist)
            (add-to-list 'ispell-skip-region-alist '("\\[\\[" . "\\]\\]"))
            (add-to-list 'ispell-skip-region-alist '("https?://" . "\\S-*"))
            (add-to-list 'ispell-skip-region-alist '("[./\\~][-a-zA-Z0-9_./\\]*"))
            ;; Disable <> auto-pairing; org uses < for template expansion
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

;; -- Babel --

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

(setq org-confirm-babel-evaluate nil)
(setq org-src-fontify-natively t)
(setq org-babel-default-header-args:lua '((:results . "output")))

(use-package ob-php
  :after org
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   (append org-babel-load-languages
           '((php . t)))))

;; -- Agenda & Capture --

(setq org-agenda-files
      (list
       (expand-file-name "inbox.org"    my/org-agenda-directory)
       (expand-file-name "tasks.org"    my/org-agenda-directory)
       (expand-file-name "meetings.org" my/org-agenda-directory)
       (expand-file-name "projects.org" my/org-agenda-directory)
       (expand-file-name "someday.org"  my/org-agenda-directory)))

(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c l") #'org-store-link)

(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@/!)" "MEETING(m)" "|" "DONE(d!)" "CANCELLED(c@)")))

(setq org-todo-keyword-faces
      '(("TODO"      . (:weight bold))
        ("NEXT"      . (:weight bold))
        ("WAIT"      . (:weight bold))
        ("MEETING"   . (:weight bold))
        ("CANCELLED" . (:weight bold))))

(setq org-highest-priority ?A
      org-default-priority  ?B
      org-lowest-priority   ?C)

(setq org-log-done 'time)

(setq org-agenda-span                    7
      org-agenda-start-on-weekday        nil
      org-agenda-window-setup            'current-window
      org-agenda-show-future-repeats     t
      org-agenda-skip-deadline-if-done   t
      org-agenda-skip-scheduled-if-done  t)

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
        ("waiting"  . ?W)))

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

;; -- Roam --

(use-package org-roam
  :custom
  (org-roam-directory "~/Zettelkasten/Org")
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ("C-c n j" . org-roam-dailies-capture-today))
  :config
  (org-roam-db-autosync-mode))

(defun my/org-roam-search-text ()
  "Search full text in org-roam-directory using ripgrep via helm."
  (interactive)
  (require 'org-roam)
  (let ((default-directory org-roam-directory)
        (helm-grep-ag-command
         "rg --color=always --smart-case --no-heading --line-number %s %s %s"))
    (helm-do-grep-ag nil)))

(global-set-key (kbd "C-c n s") #'my/org-roam-search-text)

;; -- Extras --

(use-package org-download
  :after org
  :config
  (setq org-download-image-dir              "./images"
        org-download-method                 'directory
        org-download-display-inline-images  t)
  (define-key org-mode-map (kbd "C-c i") #'org-download-clipboard))

(use-package org-modern
  :hook (org-mode . org-modern-mode))


;; ============================================================
;; Spell Checking
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
;; Finalize
;; ============================================================

(package-install-selected-packages t)
(load-file custom-file)
