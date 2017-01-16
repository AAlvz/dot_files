;; Tell emacs where is your personal elisp lib dir
(add-to-list 'load-path "~/.emacs.d/lisp/")

;; Setup puppet-mode
(autoload 'puppet-mode "puppet-mode" "Major mode for editing puppet manifests")
(add-to-list 'auto-mode-alist '("\\.pp$" . puppet-mode))

;; Setup golang-mode
;; (add-to-list 'load-path "/place/where/you/put/it/")
(add-to-list 'auto-mode-alist '("\\.go$" . go-mode))
(require 'go-mode-autoloads)

;; Setup yaml-mode
(autoload 'yaml-mode "yaml-mode" "Major mode for editing YAML files")
(add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))

;; Setup ruby-mode
(autoload 'ruby-mode "ruby-mode" "Major mode for editing ruby manifests")
(add-to-list 'auto-mode-alist '("Vagrantfile$" . ruby-mode))

;; Setup markdown-mode
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; Setup Swap Windows
(autoload 'swap-windows "swap-windows" "Swap 2 windows")
  ;; shortctut for swap windows
(global-set-key (kbd "C-c s") 'swap-windows)

;; Copy/Paste in & out of emacs with Ctrl C
(setq x-select-enable-clipboard t)
(unless window-system
(when (getenv "DISPLAY")
(defun xsel-cut-function (text &optional push)
    (with-temp-buffer
     (insert text)
     (call-process-region (point-min) (point-max) "xsel" nil 0 nil "--clipboard" "--input")))
 (defun xsel-paste-function()
    (let ((xsel-output (shell-command-to-string "xsel --clipboard --output")))
     (unless (string= (car kill-ring) xsel-output)
   xsel-output )))
 (setq interprogram-cut-function 'xsel-cut-function)
 (setq interprogram-paste-function 'xsel-paste-function)
))

;; Autocomplete git commands
(autoload 'bash-completion-dynamic-complete
  "bash-completion"
  "BASH completion hook")
(add-hook 'shell-dynamic-complete-functions
  'bash-completion-dynamic-complete)
(add-hook 'shell-command-complete-functions
  'bash-completion-dynamic-complete)

;; New line at the end of files (ask)
;;(setq require-final-newline 'ask)
;; Silently ensure newline at end of file
(setq require-final-newline t)

;; Switch to previous window
(global-set-key (kbd "C-x O") 'previous-multiframe-window)

;; Highlight characters over 80 and linees with spaces and tabs probably
;; (require 'whitespace)
;;  (setq whitespace-style '(face empty tabs lines-tail trailing))
;;  (global-whitespace-mode t)

;; No horrible tabs. (Tabs treated as spaces)
(setq c-basic-indent 2)
(setq tab-width 4)
(setq-default indent-tabs-mode nil)

;; multiterm
(require 'multi-term)
(setq multi-term-program "/bin/bash")

;; Set Backups directory
(setq backup-directory-alist `(("." . "~/.emacs_saves")))
(setq ;;version-control t     ;; Use version numbers for backups.
      ;;kept-new-versions 10  ;; Number of newest versions to keep.
      kept-old-versions 0   ;; Number of oldest versions to keep.
      delete-old-versions t ;; Don't ask to delete excess backup versions.
      backup-by-copying t)  ;; Copy all files, don't rename them.
(put 'upcase-region 'disabled nil)
