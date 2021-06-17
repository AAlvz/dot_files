;; Tell emacs where is your personal elisp lib dir

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(add-to-list 'load-path "~/.emacs.d/lisp/")

(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                     ("melpa" . "https://melpa.org/packages/")))

(setq vc-follow-symlinks t)

;; Setup puppet-mode
(autoload 'puppet-mode "puppet-mode" "Major mode for editing puppet manifests")
(add-to-list 'auto-mode-alist '("\\.pp$" . puppet-mode))

;; Setup terraform-mode
(autoload 'terraform-mode "terraform-mode" "Major mode for editing terraform scripts")
(add-to-list 'auto-mode-alist '("\\.tf$" . terraform-mode))

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

;; Setup idle-highlight-mode
(autoload 'idle-highlight-mode "idle-highlight-mode" "Highlight word under cursor" t)

(define-globalized-minor-mode global-idle-highlight-mode idle-highlight-mode
  (lambda () (idle-highlight-mode 1)))
(global-idle-highlight-mode 1)

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

;; ;; Copy/Paste to clipboard OSX
;; (defun copy-from-osx ()
;;   (shell-command-to-string "pbpaste"))

;; (defun paste-to-osx (text &optional push)
;;   (let ((process-connection-type nil))
;;     (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
;;       (process-send-string proc text)
;;       (process-send-eof proc))))

;; (setq interprogram-cut-function 'paste-to-osx)
;; (setq interprogram-paste-function 'copy-from-osx)

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
(setq tab-width 2)
(setq-default indent-tabs-mode nil)

;; Toggle truncate lines
(setq-default truncate-lines t)

;; Disable electir indent mode by default
(electric-indent-mode -1)

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

;; Set Default Theme
(load-theme 'tango-dark)

;; Visualize where parenthesis open and close
(show-paren-mode 1)

;; Always enable hs-minor-mode
(add-hook 'prog-mode-hook #'hs-minor-mode)

;; Shortcut to hide blocks
(global-set-key (kbd "C-c C-c") 'hs-hide-block)

;; Shortcut to show blocks
(global-set-key (kbd "C-c c") 'hs-show-block)

;; Shortcut to find-file-at-point
(global-set-key (kbd "C-c C-f") 'find-file-at-point)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (helm cl-lib))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Shortcut to git grep
;;(require 'helm-git-grep) ;; Not necessary if installed by package.el
(global-set-key (kbd "C-c g") 'helm-grep-do-git-grep)
;; Invoke `helm-grep-do-git-grep' from isearch.
(define-key isearch-mode-map (kbd "C-c g") 'helm-git-grep-from-isearch)
;; Invoke `helm-grep-do-git-grep' from other helm.
(eval-after-load 'helm
  '(define-key helm-map (kbd "C-c g") 'helm-git-grep-from-helm))
