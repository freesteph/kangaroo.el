;;; package --- Summary
(require 'array)
(require 'seq)
;;; Commentary:

;;; Code:
(defvar kangaroo/process-buffer-name "*temp-kangaroo*")
(defvar kangaroo/error-face '(:background "red"))
(defvar kangaroo/success-face '(:background "green"))

(defun kangaroo--find-or-create-overlay ()
  "Find or create an overlay at point."
  (and
   (search-backward "it(")
   (let ((ols (overlays-at (point)))
	 (start (point))
	 (end (save-excursion (forward-list) (point))))
     (or (and (seq-empty-p ols) (make-overlay start end))
	 (car ols)))))

(defun kangaroo/handle-output (process event)
  "Handle EVENT on PROCESS for the jest subprocess."
  (let ((ol (kangaroo--find-or-create-overlay))
	(face (or
	       (and (string-prefix-p "finished" event) kangaroo/success-face)
	       kangaroo/error-face)))
    (overlay-put ol 'face face)))

(defun kangaroo/find-current-test ()
  "Say hello."
  (interactive)
  (save-excursion
    (and
     (search-backward "it(")
     (save-excursion (search-forward-regexp "\".*\""))
     (let* ((line (+ (current-line) 1))
	    (test-name (match-string 0))
	    (cmd (format "yarn jest %s -t %s" buffer-file-name test-name))
	    (process (start-process-shell-command
		      "run-test"
		      (get-buffer-create kangaroo/process-buffer-name)
		      cmd)))
       (set-process-sentinel process 'kangaroo/handle-output)))))

(provide 'kangaroo)
;;; kangaroo.el ends here
