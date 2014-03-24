;; list variables that should be customized and call
;; `check-customized' with them.

(require 'check-customize "~/.emacs.d/check-customize.el")

(defvar check-customize-list
  '(org-directory)
  )

(check-customize check-customize-list custom-file)
