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

(defvar reloaded-namespace "user")

(defun reloaded--eval (form)
  (cider-ensure-connected)
  (reloaded--ensure-implements-reloaded-pattern)
  (cider-tooling-eval form (cider-interactive-eval-handler) reloaded-namespace))

(defun reloaded--eval-value (form)
  (nrepl-dict-get
   (cider-nrepl-sync-request:eval form reloaded-namespace)
   "value"))

(defun reloaded-init ()
  (interactive)
  (reloaded--eval "(init)"))

(defun reloaded-start ()
  (interactive)
  (reloaded--eval "(start)"))

(defun reloaded-stop ()
  (interactive)
  (reloaded--eval "(stop)"))

(defun reloaded-go ()
  (interactive)
  (reloaded--eval "(go)"))

(defun reloaded-clear ()
  (interactive)
  (reloaded--eval "(clear)"))

(defun reloaded-suspend ()
  (interactive)
  (reloaded--eval "(suspend)"))

(defun reloaded-resume ()
  (interactive)
  (reloaded--eval "(resume)"))

(defun reloaded-reset ()
  (interactive)
  (reloaded--eval "(reset)"))

(defun reloaded-reset-all ()
  (interactive)
  (reloaded--eval "(reset-all)"))

;;;###autoload
(defun reloaded--implements-reloaded-pattern ()
  (not (equal "nil" (reloaded--eval-value "(and (resolve 'component/start) (resolve 'component/stop))"))))

(defun reloaded--ensure-implements-reloaded-pattern ()
  (unless (reloaded--implements-reloaded-pattern)
    (error "This project doesn't implement the Reloaded pattern")))

(defun reloaded--reset-on-save ()
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
  :keymap  reloaded-mode-map
  :group   cider)

(provide 'reloaded-mode)

;;; reloaded-mode.el ends here
