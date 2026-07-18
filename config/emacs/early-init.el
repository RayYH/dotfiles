;;; early-init.el --- Pre-init configuration -*- lexical-binding: t; -*-

;; Defer GC during startup; restore after init for responsiveness.
(setq gc-cons-threshold  most-positive-fixnum
      gc-cons-percentage 0.6)
(defvar my/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold       (* 64 1024 1024)
                  gc-cons-percentage      0.1
                  file-name-handler-alist my/file-name-handler-alist)))

;; Suppress chrome before init.el to avoid flash.
(push '(menu-bar-lines . 0)     default-frame-alist)
(push '(tool-bar-lines . 0)     default-frame-alist)
(push '(vertical-scroll-bars)   default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist)

;; Silence the byte-compiler about vars defined in package.el.
(defvar package-quickstart)

;; In Emacs 29+ the startup sequence calls `package-activate-all' between
;; early-init.el and init.el, so we leave `package-enable-at-startup' at its
;; default (t) and DO NOT call `(package-initialize)' from init.el.
;; `package-quickstart' makes activation read a precompiled autoload bundle.
(setq site-run-file           nil
      inhibit-startup-screen  t
      package-quickstart      t
      ;; LSP perf: allow large reads from subprocesses (eglot/lsp).
      read-process-output-max (* 4 1024 1024))

;; Native compilation: keep building in the background, but don't let async
;; warnings/errors pop the *Warnings* buffer on every package build.
(when (native-comp-available-p)
  (setq native-comp-async-report-warnings-errors 'silent))
