;;; reloaded-mode.el --- Support for the Reloaded Clojure workflow with CIDER
;;
;; Author: Greg Leppert
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;; Handy hooks and functions for interacting with reloaded.repl
;; https://github.com/weavejester/reloaded.repl
;;
;;; Code:

(defgroup reloaded nil
  "Minor mode for working with the Reloaded Clojure workflow and CIDER."
  :prefix "reloaded-"
  :group 'programming
  :link '(url-link "https://github.com/leppert/reloaded-mode"))

(defcustom reloaded-namespace "user"
  "The namespace in which reloaded functions should be evaluated."
  :type '(string)
  :group 'reloaded)

(defun reloaded--eval (form)
  "Evaluate the FORM in the current CIDER session."
  (cider-ensure-connected)
  (reloaded--ensure-implements-reloaded-pattern)
  (cider-tooling-eval form (cider-interactive-eval-handler) reloaded-namespace))

(defun reloaded--eval-value (form)
  "Evaluate the FORM in the current CIDER session and return the value."
  (nrepl-dict-get
   (cider-nrepl-sync-request:eval form reloaded-namespace)
   "value"))

(defun reloaded-init ()
  "Construct the current development system."
  (interactive)
  (reloaded--eval "(init)"))

(defun reloaded-start ()
  "Start the current development system."
  (interactive)
  (reloaded--eval "(start)"))

(defun reloaded-stop ()
  "Stop the current development system."
  (interactive)
  (reloaded--eval "(stop)"))

(defun reloaded-go ()
  "Construct the current development system and start it."
  (interactive)
  (reloaded--eval "(go)"))

(defun reloaded-clear ()
  "Stop the current development system and dereference it."
  (interactive)
  (reloaded--eval "(clear)"))

(defun reloaded-suspend ()
  "Suspend the current development system."
  (interactive)
  (reloaded--eval "(suspend)"))

(defun reloaded-resume ()
  "Resume the currently suspended development system."
  (interactive)
  (reloaded--eval "(resume)"))

(defun reloaded-reset ()
  "Reset modified files in the current development system."
  (interactive)
  (reloaded--eval "(reset)"))

(defun reloaded-reset-all ()
  "Reset all files in the current development system."
  (interactive)
  (reloaded--eval "(reset-all)"))

;;;###autoload
(defun reloaded--implements-reloaded-pattern ()
  "Determine whether the current development system implements the reloaded pattern."
  (not (equal "nil" (reloaded--eval-value "(and (resolve 'component/start) (resolve 'component/stop))"))))

(defun reloaded--ensure-implements-reloaded-pattern ()
  "Throw an error if the current development system doesn't implement the reloaded pattern."
  (unless (reloaded--implements-reloaded-pattern)
    (error "This project doesn't implement the Reloaded pattern")))

(defun reloaded--reset-on-save ()
  "Reset the current development system if CIDER is connected."
  (if (cider-connected-p) (reloaded-reset)))

(defvar reloaded-mode-map
  (let ((map (make-sparse-keymap)))
    (prog1 map
      (define-key map (kbd "C-c C-r") 'reloaded-reset)))
  "Keymap for reloaded-mode.")

;;;###autoload
(add-hook 'cider-mode-hook
          '(lambda ()
             (if (reloaded--implements-reloaded-pattern) (reloaded-mode))))

(add-hook 'reloaded-mode-hook
          '(lambda ()
             (add-hook 'after-save-hook 'reloaded--reset-on-save nil 'make-it-local)))

;;;###autoload
(define-minor-mode reloaded-mode
  "Minor mode for Clojure projects using the Reloaded workflow with CIDER."
  :lighter "reloaded"
  :keymap  reloaded-mode-map)

(provide 'reloaded-mode)

;;; reloaded-mode.el ends here
