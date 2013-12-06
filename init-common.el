;; misc settings
(setq
 auto-revert-verbose nil
 column-number-mode t
 display-time-mode t
 ediff-window-setup-function (quote ediff-setup-windows-plain)
 indent-tabs-mode nil
 inhibit-startup-screen t
 frame-title-format "%b %f"
 global-auto-revert-mode t
 global-auto-revert-non-file-buffers t
 make-backup-files nil
 ring-bell-function 'ignore
 show-paren-mode t
 vc-follow-symlinks nil
 x-select-enable-clipboard t)

;; disable toolbar mode
(tool-bar-mode -1)

;; common keybindings
(defun my-bind-window-movement ()
  (global-set-key "\C-x\C-j" 'windmove-left)   
  (global-set-key "\C-x\C-l" 'windmove-right)       
  (global-set-key "\C-x\C-i" 'windmove-up)          
  (global-set-key "\C-x\C-k" 'windmove-down))
(my-bind-window-movement)

;; use ibuffer by default
 (global-set-key "\C-x\C-b" 'ibuffer)

;; wrap the shell command to be sure it's buffer is recorded
;; (otherwise it's anoying to use emacsclient from the shell)
(defun sh ()
  (interactive)
  (shell)
  (switch-to-buffer (current-buffer)))

;; deal with customize
(setq custom-file "~/.emacs.d/init-custom.el")
(load custom-file)

;; now we initialize the elpa-packages
(require 'package)
(setq 
 package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
		    ("marmalade" . "http://marmalade-repo.org/packages/")
		    ("melpa" . "http://melpa.milkbox.net/packages/")
		    ("org" . "http://orgmode.org/elpa/")
		    )
 package-enable-at-startup nil)
(package-initialize)

;; custom common package initialization
(load-file "~/.emacs.d/init-evil.el")
(load-file "~/.emacs.d/init-surround.el")
(load-file "~/.emacs.d/init-tramp.el")
(load-file "~/.emacs.d/init-ido.el")

;; load the zenburn color theme by default
(load-theme 'zenburn t)
