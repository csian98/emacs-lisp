;;; package --- Summary
;;; Commentary:

;;;
;;  File   : Emacs customization file
;;  Name   : ~/.emacs.d/init.el
;;  Author : Choi JeongHoon <csian7386@gmail.com>
;;  Init   : 24 June 2023
;;
;;  Copyright (C) 2023 Choi JeongHoon
;;  The content of this files is confidential and intended for the private.
;;  It is strictly forbidden to share any part of this files with any third party,
;;  withouth a written consent.
;;;

;;; Code:
(let* ((reqver "28.2"))
  (when (version< emacs-version reqver)
    (error "Emacs v%s or higher is required" reqver)))

;(if init-file-debug
;		(setq use-package-verbose t
;					use-package-expand-minimally nil
;					use-package-compute-statistics t
;					debug-on-error t)
;	(setq use-package-verbose nil
;				use-package-expand-minimally t))

(set-default-coding-systems 'utf-8)

(setq gc-cons-threshold (* 50 1000 1000))
(add-hook 'emacs-startup-hook
		  (lambda ()
			(message "*** Emacs loaded in %s with %d garbage collections."
					 (format "%.2f seconds" (float-time (time-subtract after-init-time before-init-time)))
					 gcs-done)))

(setq warning-minimum-level :emergency)
(setq-default message-log-max nil)
(kill-buffer "*Messages*")

(setq initial-scratch-message
			(concat ";;;\n"
					"; Emacs *scratch* buffer\n"
					"; Jeong Hoon Choi - Sian\n"
					";;;\n\n"))

(setq image-types (cons 'svg image-types))

(exec-path-from-shell-copy-envs '("LANG" "LC_ALL" "LC_CTYPES"))

;;; PACKAGE Settings

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
						 ("melpa-stable" . "https://stable.melpa.org/packages/")
						 ("org" . "https://orgmode.org/elpa/")
						 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)

(unless package-archive-contents
    (package-refresh-contents))

(unless (package-installed-p 'use-package)
    (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package auto-package-update
  :custom
    (auto-package-update-interval 7)
    (auto-package-update-prompt-before-update t)
    (auto-package-update-hide-results t)
    :config
    (auto-package-update-maybe)
    (auto-package-update-at-time "22:00"))

(setq ns-pop-up-frames nil)

(toggle-frame-tab-bar)

(use-package command-log-mode)

(use-package diminish)

(use-package smart-mode-line
	:config
	(setq sml/no-confirm-load-theme t)
	(sml/setup)
	(setq sml/mode-width 'right
				sml/name-width 60))

(use-package minions
	:hook (doom-modeline-mode . minions-mode))

(use-package doom-modeline
	:ensure t
	:init (doom-modeline-mode 1)
	:custom
	(doom-modeline-height 20)
	(doom-modeline-bar-width 6))

(use-package yasnippet :ensure t)

(use-package which-key
	:config (which-key-mode))

(use-package company
	:after lsp-mode
	:hook (prog-mode . company-mode)
	:bind (:map company-active-map
							("<tab>" . company-complete-session))
	(:map lsp-mode-map
				("<tab>" . company-indent-or-complete-common))
	:custom
	(company-minimum-prefix-length 1)
	(company-idle-delay 0.0))

(use-package company-box
	:hook (company-mode . company-box-mode))

(require 'openwith)
(setq openwith-associations
	  (list
	   (list (openwith-make-extension-regexp
			  '("mpg" "mpeg" "mp3" "mp4" "avi" "wmv"
				"wav" "mov" "flv" "ogm" "ogg" "mkv"))
			 "mpv"
			 '(file))
	   (list (openwith-make-extension-regexp
			  '("xbm" "pbm" "pgm" "ppm" "pnm" "png"
				"gif" "bmp" "tif" "jpeg"))
			 "sxiv"
			 '(file))
	   (list (openwith-make-extension-regexp
			  '("pdf"))
			 "zathura"
			 '(file))))
(openwith-mode 1)

;;; ENVIRONMENT

;; load custom.el
(setq custom-file (expand-file-name "config/custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
    (load custom-file))

;; windows
(if (window-system)
		(set-frame-height (selected-frame) 40))
(if (window-system)
		(set-frame-width (selected-frame) 130))

(setq frame-title-format "Emacs - %b")
(setq icon-title-format "Emacs - %b")
(setq frame-title-format '(buffer-file-name "Emacs - [%f]"
					    (dired-directory dired-directory "Emacs - [%b]")))

;; cursor
(setq-default cursor-type 'bar)		; bar box hbar
(global-hl-line-mode 1)
(transient-mark-mode 1)

(global-display-line-numbers-mode 1)

(dolist (mode '(org-mode-hook
				term-mode-hook
				eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; mouse
(mouse-wheel-mode 1)

;; tab
;(global-set-key (kbd "TAB") 'self-insert-command)
(setq indent-tabs-mode nil)
(setq-default tab-width 4)

;; completion
(progn
  (show-paren-mode t)
  (setq show-paren-style 'parenthesis)
  (setq show-paren-display 0)
  (setq show-paren-delay 0))

(progn
  (electric-pair-mode 1)
  (setq electric-pair-pairs
        '((?\( . ?\))
          (?\{ . ?\})
          (?\[ . ?\])
          ;(?\' . ?\')
          (?\" . ?\")))
)

;; settings
(recentf-mode t)	; M-x recentf-open-files
(setq history-length 25)
(savehist-mode 1)
(save-place-mode 1)
(setq use-dialog-box nil)
(global-auto-revert-mode 1)		; M-x revert-buffer

;;; MAJOR MODE
; https://emacs-lsp.github.io/lsp-mode/page/languages/

(which-key-mode)

(setq lang-env-file (expand-file-name "config/env-path.el" user-emacs-directory))
(when (file-exists-p lang-env-file)
  (load lang-env-file))

(require 'dap-mode)
(dap-mode t)
(dap-ui-mode t)
(dap-tooltip-mode t)
(dap-ui-controls-mode t)
(tooltip-mode t)

; load major.el (Language settings)
(setq major-file (expand-file-name "config/major.el" user-emacs-directory))
(when (file-exists-p major-file)
  (load major-file))

; ide-mode
; load ide-windows.el
(setq ide-file (expand-file-name "config/ide-windows.el" user-emacs-directory))
(when (file-exists-p ide-file)
  (load ide-file))

;;; EMAIL
; mu4e
; load mu42-file.el
(when (eq system-type 'darwin)
	(setq mu4e-file (expand-file-name "config/mu4e-file.el" user-emacs-directory))
	(when (file-exists-p mu4e-file)
  	(load mu4e-file)))

;;; GnuPG
; epa
(setq gpg-file (expand-file-name "config/gpg.el" user-emacs-directory))
(when (file-exists-p gpg-file)
	(load gpg-file))

;;; LangTool
; langtool
(when (eq system-type 'darwin)
	(setq langtool-file (expand-file-name "config/langtool.el" user-emacs-directory))
	(when (file-exists-p langtool-file)
		(load langtool-file)))

;;; Xwidget
; webkit browse
(when (eq system-type 'darwin)
	(setq xwidget-file (expand-file-name "config/xwidget.el" user-emacs-directory))
	(when (file-exists-p xwidget-file)
		(load xwidget-file)))

;;; KEY BINDING (GLOBAL)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

; C-c C-j: term line mode
; C-c C-k: term char mode
(global-set-key [f1] (lambda () (interactive) (term (getenv "SHELL"))))
(global-set-key [f2] (lambda () (interactive) (xwidget-webkit-browse-url "https://www.google.com")))
(global-set-key [f3] 'mu4e)
(global-set-key [f4] 'org-agenda)
; [f5]: run
; [f6]: release compile (C/C++, asm)
; [f7]: debug compile (C/C++)
; [f8]: debugging Codes (C/C++)

(defun hexl-edit ()
	(hexl-mode)
	(calculator)
	(other-window -1))

; C-M-d: insert a byte with decimal
; C-M-o: insert a byte with octal
; C-M-x: insert a byte with hex
; M-g: move to an address specified in hex
; M-j: move to an address specified in decimal
; C-c C-c: Leave Hexl-mode

; calculator
; H: hex
; O: octal
; D: decimal
(global-set-key [f9] (lambda () (interactive) (hexl-edit)))

(global-set-key [f10] 'toggle-frame-fullscreen)
(global-set-key [f12] 'modus-themes-toggle)

(global-set-key "\C-s" 'swiper)
(global-set-key (kbd "C->") 'indent-rigidly-right-to-tab-stop)
(global-set-key (kbd "C-<") 'indent-rigidly-left-to-tab-stop)

;;; CODE
; load start.org file
(when (< (length command-line-args) 2)
		(setq start-buffer-file (expand-file-name "config/start-buffer.el" user-emacs-directory))
		(when (file-exists-p start-buffer-file)
  		(load start-buffer-file)))

;;; init.el ends here
