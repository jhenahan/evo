(package-initialize)

(defun reload-user-init-file()
  (interactive)
  (load-file user-init-file)
  (load (concat user-emacs-directory "lisp/evo")))

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

(defun my-tangle-config-org (file output)
  "This function will write all source blocks from =evo.org= into
=evo.el= that are ...

- not marked as =tangle: no=
- have a source-code of =emacs-lisp="
  (require 'org)
  (let* ((body-list ())
         (output-file output)
         (org-babel-default-header-args (org-babel-merge-params
                                         org-babel-default-header-args
                                         (list (cons :tangle output-file)))))
    (message "Writing %s ..." output-file)
    (save-restriction
      (save-excursion
        (org-babel-map-src-blocks file
          (let* ((info (org-babel-get-src-block-info 'light))
                 (tfile (cdr (assq :tangle (nth 2 info)))))
            (save-excursion
              (catch 'exit
                (when (looking-at org-outline-regexp)
                  (goto-char (1- (match-end 0))))))
            (unless (or (string= "no" tfile)
                        (not (string= "emacs-lisp" lang)))
              (add-to-list 'body-list body)))))
      (with-temp-file output-file
        (insert (apply 'concat (reverse body-list))))
      (message "Wrote %s ..." output-file))))

(save-window-excursion
  (let ((tmp-file (make-temp-file "evo-includes.org"))
  (org-export-time-stamp-file nil))
    (with-temp-buffer
      (insert-file-contents (concat user-emacs-directory "evo.org"))
      (org-org-export-as-org)
      (with-temp-file tmp-file
        (insert-buffer "*Org ORG Export*"))
      (my-tangle-config-org tmp-file (concat user-emacs-directory "lisp/evo.el"))
      ;(with-current-buffer (find-file tmp-file)
      ;  (org-mode)
      ;  (byte-compile-file
      ;   (car
      ;    (org-babel-tangle
      ;     nil
      ;     (concat user-emacs-directory "lisp/evo.el")
      ;     'emacs-lisp)))))
      (with-temp-file (concat user-emacs-directory "README.org")
        (insert-file-contents tmp-file))
      (mapcar 'kill-buffer
              `("*Org ORG Export*")))))

(add-to-list 'load-path (concat user-emacs-directory "lisp"))
(require 'evo)
