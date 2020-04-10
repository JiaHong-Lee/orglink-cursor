;;; orglink-cursor.el --- displays org raw link in minibuffer after a time interval

;; Copyright (C) 2020 Lee Jia Hong

;; Author   : Lee Jia Hong <jiahong@zacque.tk>
;; Created  : 7th April 2020
;; Modified :
;; Version  : 0.0.1
;; Keywords : org-mode
;;
;;; Commentary:
;; Provides a minor-mode to display org raw link in minibuffer.

;;; code:

(defgroup orglink-cursor nil
  "orglink-cursor"
  :prefix "orglink-cursor-"
  :group 'convenience)

(defcustom orglink-cursor-timer 1
  "A timer counting in seconds; when it fires, it displays the raw-link of the org"
  :group 'orglink-cursor
  :type 'int)

(defvar orglink-cursor--stored-link nil
  "A variable to hold the raw link at point. When the timer fires, this value is output to the minibuffer area.")

(defvar orglink-cursor--current-timer nil
  "A variable keeping track of the current running timer.")

(defun orglink-cursor--format-into-raw-string (output)
  "Handle % signs in the output string. E.g. \"info:org.info.gz#Adding%20hyperlink%20types\"."
  (let* ((result (replace-regexp-in-string "%20" " " output))
         (result (replace-regexp-in-string "%" "%%" result)))
    result))

(defun orglink-cursor--display-raw-link ()
  "Display raw link at the echo area. And reset timer."
  (message (orglink-cursor--format-into-raw-string orglink-cursor--stored-link))
  (setq orglink-cursor--current-timer nil))

(defun orglink-cursor--get-raw-link-at-point ()
  "Extract the raw-link from the org link under cursor. Can be used for debug purposes."
  (let* ((org-context (org-element-context))
         (type (car org-context))
         (content (cadr org-context)))
    (when (eq type 'link)
      (plist-get content :raw-link))))

;;;###autoload
(defun orglink-cursor-display-at-interval ()
  "Reset a timer. And display raw link at interval."
  (when orglink-cursor--current-timer
    (cancel-timer orglink-cursor--current-timer))
  (let ((raw-link (orglink-cursor--get-raw-link-at-point)))
    (if raw-link
        (setq orglink-cursor--stored-link raw-link
              orglink-cursor--current-timer (run-at-time orglink-cursor-timer nil 'orglink-cursor--display-raw-link))
      (setq orglink-cursor--stored-link nil
            orglink-cursor--current-timer nil))))

;;;###autoload
(define-minor-mode orglink-cursor-mode
  "Minor mode for auto displaying raw link of org-link under cursor."
  nil nil (make-sparse-keymap)
  (if orglink-cursor-mode
      (add-hook 'post-command-hook 'orglink-cursor-display-at-interval t t)
    (remove-hook 'post-command-hook 'orglink-cursor-display-at-interval t)))

(provide 'orglink-cursor)

;;; orglink-cursor.el ends here
