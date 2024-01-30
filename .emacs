;;; emacs -- Summary.

;;; Commentary:

;;; Code:

(require 'package)

(setq package-archives '(("ELPA" . "http://tromey.com/elpa/")
                          ("gnu" . "http://elpa.gnu.org/packages/")
                          ("melpa" . "http://melpa.org/packages/")))
                          ;; ("marmalade" . "http://marmalade-repo.org/packages/")))

(package-initialize)
(unless (package-installed-p 'use-package)
(package-refresh-contents)
(package-install 'use-package))

(add-to-list 'load-path "~/.emacs.d/lisp/")
(add-to-list 'load-path "~/documents/copilot/copilot.el/")

(require 'copilot)
(add-hook 'prog-mode-hook 'copilot-mode)
(define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
(define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion)
(define-key copilot-mode-map (kbd "M-<down>") #'copilot-next-completion)
(define-key copilot-mode-map (kbd "M-<up>") #'copilot-previous-completion)


;;(require 'copilot-balancer)
;; Could be useful:
;; (add-to-list 'copilot-major-mode-alist '("enh-ruby" . "ruby"))

;; Show Line row Number
(setq column-number-mode t)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Auto insert closing bracket
(electric-pair-mode 1)

;; Init Winner mode. Save layout of windows to go back
(winner-mode 1)

;; Idle highlight
(use-package idle-highlight-mode
  :config (setq idle-highlight-idle-time 0.2)
  :hook ((prog-mode text-mode) . idle-highlight-mode))

;; Smex: Guidance for M-x
(require 'smex)
(global-set-key (kbd "M-x") 'smex)

;; Setup Swap Windows
(autoload 'swap-windows "swap-windows" "Swap 2 windows")
(global-set-key (kbd "C-c s") 'swap-windows)

(defun wsl-copy (start end)
    "START Copy a string from Emscs using Windows' clip.exe until END."
    (interactive "r")
    (copy-region-as-kill start end)
    (shell-command-on-region start end "clip.exe"))
    (global-set-key (kbd "C-c x")  'wsl-copy)

;; Silently ensure newline at end of file
(setq require-final-newline t)

;; Switch to previous window
(global-set-key (kbd "C-x O") 'previous-multiframe-window)

;;Highlight characters over 80 and linees with spaces and tabs probably
(require 'whitespace)
 (setq whitespace-style '(face empty tabs lines-tail trailing))
 (global-whitespace-mode t)

;; No horrible tabs. (Tabs treated as spaces)
(setq c-basic-indent 4)
(setq tab-width 4)
(setq-default indent-tabs-mode nil)

;; Disable electir indent mode by default
(electric-indent-mode -1)

;; Set Backups directory
(setq backup-directory-alist `(("." . "~/.emacs_saves")))
(setq version-control t     ;; Use version numbers for backups.
      kept-new-versions 10  ;; Number of newest versions to keep.
      kept-old-versions 5   ;; Number of oldest versions to keep.
      delete-old-versions t ;; Don't ask to delete excess backup versions.
      backup-by-copying t)  ;; Copy all files, don't rename them.
(put 'upcase-region 'disabled nil)

;; Set Default Theme
;; (load-theme 'tango-dark)
(load-theme 'wombat)

;; Visualize where parenthesis open and close
(show-paren-mode 1)

;; Always enable hs-minor-mode. Hide/show blocks
(add-hook 'prog-mode-hook #'hs-minor-mode)
(global-set-key (kbd "C-c C-c") 'hs-hide-block)
(global-set-key (kbd "C-c c") 'hs-show-block)

;; (defun my-q-r ()
;;   "Query-replace text of active region with text you're prompted for."
;;   (interactive)
;;   (replace-regexp "False" "\"False\"")
;;   (goto-line 1)
;;   (replace-regexp "None" "\"None\"")
;;   (goto-line 1)
;;   (replace-regexp "'" "\"")
;;   (goto-line 1)
;;   (replace-regexp "True" "\"True\"")
;;   (goto-line 1))

;; ;; Shortcut to run custom query replace
;; (global-set-key (kbd "C-c C-r") 'my-q-r)

;; (provide '.emacs)
;;; .emacs ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(yaml-mode eglot use-package s protobuf-mode json-mode editorconfig dash auto-complete async)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
