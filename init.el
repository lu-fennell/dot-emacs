;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization and bootstrapping 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq my-emacs-home (file-name-directory user-init-file))
(when (string= (getenv "HOME") (directory-file-name my-emacs-home))
  (error "Initialization error: my-emacs-home is the same as HOME"))

;; personal extensions
(add-to-list 'load-path (concat my-emacs-home "lib"))

;; start a server if requested by EMACS_SERVER_FILE
(let ((server-file (getenv "EMACS_SERVER_NAME")))
  (when server-file
    (setq server-name server-file)
    (server-start)))

;; init package management
(require 'package)
(setq 
 package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
		    ("marmalade" . "http://marmalade-repo.org/packages/")
		    ("melpa" . "http://melpa.milkbox.net/packages/")
		    ("org" . "http://orgmode.org/elpa/")
		    )
 package-enable-at-startup nil)
(package-initialize)

;; initialize customization
(setq custom-file (concat my-emacs-home "init-custom.el"))
(load custom-file)
(load-file (concat my-emacs-home "perform-customization-check.el"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Core editor settings 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq
 auth-sources '("~/.authinfo.gpg")
 auto-revert-verbose nil
 auto-save-list-file-prefix "~/.cache/emacs.d/auto-save-list/.saves-"
 column-number-mode t
 display-time-mode t
 frame-title-format "%b %f"
 global-auto-revert-mode t
 global-auto-revert-non-file-buffers t
 global-auto-revert-ignore-modes '(buffer-menu-mode)
 indent-tabs-mode nil
 inhibit-startup-screen t
 make-backup-files nil
 ps-print-header nil
 ring-bell-function 'ignore
 vc-follow-symlinks nil
 x-select-enable-clipboard t
 )
;; switches
(show-paren-mode t)
;; bindings
(defun my-bind-window-movement ()
  (global-set-key "\C-x\C-j" 'windmove-left)   
  (global-set-key "\C-x\C-l" 'windmove-right)       
  (global-set-key "\C-x\C-i" 'windmove-up)          
  (global-set-key "\C-x\C-k" 'windmove-down))
(my-bind-window-movement)
;; hooks
(add-hook 'text-mode-hook
          'turn-on-flyspell)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package customization 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'use-package)

;; path initialization
;; agda
(condition-case err
    (load-file (shell-command-to-string "agda-mode locate"))
  (error (message "Warning: %s" (error-message-string err))))
;; coq
;; TODO: why isn't nix handling this?
(add-to-list 'load-path "~/.nix-profile/share/emacs/site-lisp/ProofGeneral/generic")

;; begin config
(use-package vc
  :init (progn
          (setq
           vc-follow-symlinks nil
           )))

(use-package ediff
  :init (setq ediff-window-setup-function (quote ediff-setup-windows-plain)))

(use-package paredit
  :ensure paredit
  :init (add-hook 'emacs-lisp-mode-hook (lambda () (paredit-mode t))))

;; evil mode
(use-package evil
  :ensure evil
  :init (progn
	  (evil-mode t)
	  (setq
	   evil-default-cursor '(t ignore)
	   evil-want-fine-undo t
	   )
	  (load-file (concat my-emacs-home "perform-evil-mode-bindings.el"))))
(use-package surround
  :ensure surround
  :init (global-surround-mode t))
;; end evil mode

(use-package goto-last-change
  :ensure goto-last-change)

(use-package tramp
  :init (add-to-list 'tramp-remote-path "/var/run/current-system/sw/bin"))

(use-package ido
  :init (progn
	  ;; vars
	  (setq 
	   ido-auto-merge-work-directories-length -1
	   ido-default-buffer-method (quote selected-window)
	   ido-default-file-method (quote selected-window)
	   ido-enable-flex-matching t
	   ido-show-dot-for-dired t)
	  ;; switches
	  (ido-mode t))) 

(use-package auctex
  :ensure auctex
  :mode ("\\.tex\\'" . LaTeX-mode)
  :init
  ;; TODO: why is `config' not working
  (progn
    (use-package my-synctex)
    (add-hook 'LaTeX-mode-hook
	      ;; dependencies
	      '(lambda ()
		 (use-package my-LaTeX-environment)
		 ;; config
		 (setq
		  reftex-plug-into-AUCTeX t
		  TeX-auto-save t
		  TeX-PDF-mode t
		  TeX-parse-self t
		  TeX-source-correlate-mode t)
		 ;; keybindings
		 (define-key LaTeX-mode-map (kbd "M-q") 'noop)
		 (define-key LaTeX-mode-map (kbd "C-c C-e") 'my-LaTeX-environment)
		 (define-key LaTeX-mode-map (kbd "SPC") 'my-LaTeX-break-after-sentence-or-space)
		 (push '(?% . ("$" . "$")) surround-pairs-alist)
		 ;; switches
		 (turn-on-reftex)
		 (outline-minor-mode t)
		 (visual-line-mode t)
		 (set (make-local-variable 'visual-line-fringe-indicators) t)))))

(use-package org
  :ensure org
  :mode ("\\.org\\'" . org-mode)
  :init
  (progn
    (use-package dired-fm)
    (setq
     org-highest-priority ?A
     org-default-priority ?M
     org-lowest-priority  ?Z

     org-M-RET-may-split-line '((default))
     org-checkbox-hierarchical-statistics nil
     org-enforce-todo-checkbox-dependencies t
     org-enforce-todo-dependencies t
     org-hierarchical-todo-statistics nil
     org-mobile-force-id-on-agenda-items nil
     org-pretty-entities nil
     org-startup-indented t
     org-yank-adjusted-subtrees t
     ;; export
     org-export-latex-default-packages-alist '(("" "amsmath" nil)
					       ("AUTO" "inputenc" t)
					       ("T1" "fontenc" t)
					       ("" "fixltx2e" nil)
					       ("" "graphicx" t)
					       ("" "longtable" nil)
					       ("" "float" nil)
					       ("" "wrapfig" nil)
					       ("" "soul" t)
					       ("" "textcomp" t)
					       ("" "marvosym" t)
					       ("" "wasysym" t)
					       ("" "latexsym" t)
					       ("" "amssymb" t)
					       ("" "hyperref" nil)
					       "\\tolerance=1000")
     org-export-latex-listings t
     org-file-apps '((auto-mode . emacs)
		     ("\\.mm\\'" . default)
		     ("\\.x?html?\\'" . system)
		     (system . (dired-fm-spawn "xdg-open" (list file)))
		     ("\\.pdf\\'" . system))
     org-format-latex-options '(:foreground default
					    :background default
					    :scale 1.3
					    :html-foreground "Black"
					    :html-background "Transparent"
					    :html-scale 1.0
					    :matchers ("begin" "$1" "$" "$$" "\\(" "\\["))
     )
    ;; keybindings
    ;; TODO: why is :bind not working?
    (bind-key "\C-ca"  'org-agenda)
    (bind-key "\C-cc"  'org-capture)
    (add-to-list 'evil-motion-state-modes 'org-agenda-mode)
    (evil-define-key 'motion org-agenda-mode-map
      "g" (lambda () (interactive) (org-agenda-redo t))
      "+" 'org-agenda-priority-up
      "-" 'org-agenda-priority-down)
    ;; hooks
    (add-hook 'org-load-hook
    	      (lambda ()
    		(use-package my-org-utils)
    		(use-package my-org-fixes)
    		;; set the following in the load hook in order to access org-directory
    		(setq org-agenda-files
    		      (concat (file-name-as-directory org-directory)
    			      "agenda-files.lst")
                      org-default-notes-file
                      (concat (file-name-as-directory org-directory)
    			      "notes.org"))))
    (add-hook 'org-mode-hook
    	      (lambda ()
    		(flyspell-mode -1)))
    (add-hook 'org-after-todo-statistics-hook 'org-summary-todo)
    (add-hook 'calendar-today-visible-hook 'calendar-mark-today)
    ))

(use-package dired
  :init
  (progn
    (use-package dired-details+
      :ensure dired-details+)
    (setq
     dired-bind-jump nil
     dired-details-hidden-string ""
     ;; magic copy/rename targets (really cool)
     dired-dwim-target t
     ;; directories should be listed first
     dired-listing-switches "-lah --group-directories-first"
     dired-omit-files "^\\.?#\\|^\\.$\\|^\\.[^\\.].*$"
     dired-omit-verbose nil
     dired-recursive-copies 'always
     dired-recursive-deletes 'always)
    (add-hook 'dired-mode-hook
	      (lambda ()
		(load "dired-x" nil t)
		(dired-omit-mode 1)
		(auto-revert-mode t))
              ;; keybindings
              (evil-define-key 'normal dired-mode-map ")"
                'dired-details-toggle))
    ;; TODO: is this still needed?
    (add-hook 'dired-load-hook (lambda ()
				 (load "dired-x")))))

(use-package ispell
  :init
  (progn
    (use-package flyspell)
    (use-package auto-dictionary
      :ensure auto-dictionary)
    (add-hook 'flyspell-mode-hook
	      (lambda ()
		(auto-dictionary-mode 1)
		;; keybindings
		(define-key flyspell-mode-map (kbd "M-TAB") nil)
		(define-key flyspell-mode-map (kbd "C-<tab>") 
		  'flyspell-auto-correct-word)))))


;; coq
(use-package proof-site
  :init
  (progn
    (add-hook 'coq-mode-hook
  	      (lambda ()
  		(setq
                 coq-one-command-per-line nil
                 coq-script-indent nil
                 proof-find-theorems-command "SearchAbout %s"
                 proof-auto-action-when-deactivating-scripting (quote retract)
                 proof-electric-terminator-enable nil
                 proof-follow-mode (quote ignore)
                 proof-imenu-enable nil
                 proof-script-fly-past-comments t
                 proof-strict-read-only t
                 proof-three-window-enable nil
		 proof-auto-raise-buffers nil)))))

(use-package agda2
  :init
  (progn
    (setq agda2-include-dirs '("." "./lib/src"))
    (add-hook 'agda2-mode-hook
              (lambda ()
                (dolist (th custom-enabled-themes) (disable-theme th))))))


(use-package haskell-mode
  :ensure haskell-mode
  ;; TODO: should work without pair, but simply the pattern (see github docs)
  :mode ("\\.l?hs\\'" . haskell-mode)
  :init (add-hook 'haskell-mode-hook
		  (lambda ()
		    ;; switches
		    (use-package hi2
		      :ensure hi2)
		    (turn-on-hi2)
		    ;;(turn-on-haskell-simple-indent)
		    ;; keybindings
		    (evil-define-key 'insert haskell-mode-map (kbd "RET") 'newline)
		    (define-key haskell-mode-map (kbd "C-,") 'haskell-move-nested-left)
		    (define-key haskell-mode-map (kbd "C-.") 'haskell-move-nested-right)
		    (evil-define-key 'normal haskell-mode-map (kbd "C-,") 'haskell-move-nested-left)
		    (evil-define-key 'normal haskell-mode-map (kbd "C-.") 'haskell-move-nested-right)
		    (define-key haskell-mode-map [f8] 'haskell-navigate-imports)
		    (evil-define-key 'normal haskell-mode-map [f8] 'haskell-navigate-imports)
		    )))

;; TODO: make a melpa package
(use-package ottmode)

(use-package bbdb
  :ensure bbdb
  :init (progn
	  (setq bbdb-complete-mail-allow-cycling t)
	  (bbdb-initialize 'gnus 'message)))

(use-package fsharp-mode
  :ensure fsharp-mode
  :mode ("\\.fsi?\\'" . fsharp-mode)
  :init (setq inferior-fsharp-program "fsi --readline-"
	      fsharp-compiler "fsc"))

;; ocaml
(use-package tuareg
  :ensure tuareg
  :mode ("\\.ml\\'" . tuareg-mode))

(use-package markdown-mode
  :ensure markdown-mode
  :mode ("\\.md\\'" . markdown-mode)
  :init (add-hook 'markdown-mode-hook (lambda ()
					(require 'org)
					(orgtbl-mode t))))

;; mail
;; TODO: maybe only load this when starting gnus-standalone?
(use-package gnus
  :init (progn
	  (setq gnus-propagate-marks t
		gnus-save-newsrc-file nil
		gnus-use-dribble-file nil
		gnus-agent nil
		gnus-summary-line-format "%U%R%I %&user-date; %(%[%-23,23f%]%) %s\n"
		gnus-gcc-mark-as-read t
		mail-user-agent 'gnus-user-agent
		nnmail-crosspost nil)
	  (use-package my-mbsync)
	  (define-key gnus-group-mode-map
	    (kbd "C-c g")
	    'my-mbsync-group)
	  (define-key gnus-summary-mode-map
	    (kbd "C-c g")
	    'my-mbsync-summary)
	  ;; sync on startup
	  (add-hook 'gnus-startup-hook 'my-mbsync-group)
	  ;; sync mark updates
	  (let ((mail-update-hooks
		 '(
		   gnus-exit-group-hook
		   gnus-summary-article-delete-hook
		   ;; TODO: determine if it is usefull to update after expirery after all
		   ;; gnus-summary-article-expire-hook
		   gnus-summary-article-move-hook
		   message-sent-hook
		   )))
	    (dolist (hook mail-update-hooks)
	      (add-hook hook 'my-mbsync-update)))))
(use-package message
  :init (progn
	  (setq message-citation-line-format "On %a, %b %d %Y at %R %z, %N wrote:\n"
		message-citation-line-function 'message-insert-formatted-citation-line
		message-confirm-send t
		message-sendmail-f-is-evil t
		mm-text-html-renderer (quote w3m)
		mm-text-html-renderer 'w3m
		)
	  (add-hook 'mail-mode-hook 'mail-abbrevs-mode)
	  (use-package nnir)
	  (use-package w3m
	    :ensure w3m
	    :init (define-key
		    w3m-minor-mode-map (kbd "<RET>")
		    'w3m-view-url-with-external-browser))))


;;; Load program specific init files
(let ((program (getenv "EMACS_PROGRAM")))
  (setenv "EMACS_PROGRAM")
  (when program
    (message "Loading program: %s" program)
    (load-file (concat my-emacs-home (format "init-%s.el" program)))))
