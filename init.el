(package-initialize)

(let
    ((org-location
      (expand-file-name "modules/org-mode/lisp"
		       user-emacs-directory))
     (org-contrib
      (expand-file-name "modules/org-mode/contrib/lisp"
			user-emacs-directory)))
  (when (file-exists-p org-location)
    (add-to-list 'load-path org-location)
    (add-to-list 'load-path org-contrib)
    (require 'org)))

(require 'ob-tangle)
;;(setq debug-on-error t)
(save-window-excursion
  (let ((tmp-file (make-temp-file "evo-includes.org"))
	(org-export-time-stamp-file nil))
    (with-temp-buffer
      (insert-file-contents (concat user-emacs-directory "evo.org"))
      (org-org-export-as-org)
      (with-temp-file tmp-file
	(insert-buffer "*Org ORG Export*"))
      (with-current-buffer (find-file tmp-file)
	(org-mode)
	(byte-compile-file
	 (car
	  (org-babel-tangle
	   nil
	   (concat user-emacs-directory "lisp/evo.el")
	   'emacs-lisp)))))
    (with-temp-file "README.org"
      (insert-file-contents tmp-file))
    (mapcar 'kill-buffer
	    `("*Org ORG Export*"
	      ,(file-name-nondirectory tmp-file)))))

(add-to-list 'load-path (concat user-emacs-directory "lisp"))
(require 'evo)
