;;; init --- Alfonso's Emacs -*- lexical-binding: t; -*-

;; Start server so emacsclient can connect to this instance
(server-start)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize packages   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'package)

(setq package-archives '(("gnu"    . "https://elpa.gnu.org/packages/")
                          ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                          ("melpa"  . "https://melpa.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))

(add-to-list 'load-path "~/.emacs.d/lisp/")
(load "popon")
(load "subr-x")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Defaults & built-in modes ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(windmove-default-keybindings)
(xterm-mouse-mode)
(load-theme 'misterioso)

;; Active window: bright blue mode line
(set-face-attribute 'mode-line nil
                    :background "#2257A0"
                    :foreground "#FFFFFF"
                    :box '(:line-width 2 :color "#2257A0"))
;; Inactive windows: dim gray mode line
(set-face-attribute 'mode-line-inactive nil
                    :background "#3E3E3E"
                    :foreground "#808080"
                    :box '(:line-width 2 :color "#3E3E3E"))

(recentf-mode 1)
(setq history-length 25)
(savehist-mode 1)
(save-place-mode 1)
(put 'set-goal-column 'disabled nil)
(winner-mode 1)
(setq major-mode 'text-mode)
(add-hook 'find-file-hook 'normal-mode)
(show-paren-mode 1)
(setq column-number-mode t)
(global-display-line-numbers-mode)
(electric-pair-mode 1)
(electric-indent-mode 1)

(with-eval-after-load 'consult
  (setq consult-buffer-completion-style 'orderless))
(setq require-final-newline t)

;; Whitespace: highlight tabs, trailing spaces, long lines
(require 'whitespace)
(setq whitespace-style '(face empty tabs lines-tail trailing))
(add-hook 'prog-mode-hook #'whitespace-mode)
(add-hook 'text-mode-hook #'whitespace-mode)

;; Clipboard integration (works on macOS GUI, X11, and terminal via xclip)
(setq select-enable-clipboard t)
(setq select-enable-primary t)
(setq x-select-enable-clipboard-manager t)
(use-package xclip
  :ensure t
  :config
  (xclip-mode 1))

;; Backups
(setq backup-directory-alist `(("." . "~/.emacs_saves")))
(setq version-control t
      kept-new-versions 10
      kept-old-versions 5
      delete-old-versions t
      backup-by-copying t)

(put 'upcase-region 'disabled nil)
(add-hook 'prog-mode-hook #'hs-minor-mode)

;; Grep template - update the search term as needed
;; (setq grep-find-template "grep -C2 -ri --color=auto -nH --null -e \"SEARCH_TERM\" --exclude-dir={node_modules,.terraform,.git} .")

;; Idle highlight
(require 'idle-highlight-mode)
(add-hook 'after-change-major-mode-hook 'idle-highlight-mode)
(set-face-attribute 'idle-highlight nil :background "#FFFFCC" :foreground "#333333")

;;;;;;;;;;;;;;;;;;;
;; Use-packages  ;;
;;;;;;;;;;;;;;;;;;;

(use-package kubernetes
  :ensure t)

(use-package company
  :ensure t
  :defer 0.1
  :config
  (global-company-mode t)
  (setq-default
   company-idle-delay 0.9
   company-require-match nil
   company-minimum-prefix-length 0
   company-frontends '(company-pseudo-tooltip-frontend company-preview-frontend)))

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(use-package idle-highlight-mode
  :ensure t
  :config (setq idle-highlight-idle-time 0.2)
  :hook ((prog-mode text-mode) . idle-highlight-mode))

(use-package savehist
  :init (savehist-mode))

(use-package vertico
  :ensure t
  :init (vertico-mode))

(use-package marginalia
  :ensure t
  :bind (:map minibuffer-local-map ("M-A" . marginalia-cycle))
  :init (marginalia-mode))

;; Codeium - disabled (uncomment to re-enable)
;; Requires: git clone https://github.com/Exafunction/codeium.el ~/.emacs.d/codeium.el
;; (when (file-directory-p "~/.emacs.d/codeium.el/")
;;   (add-to-list 'load-path "~/.emacs.d/codeium.el/")
;;   (use-package codeium
;;     :init
;;     (add-to-list 'completion-at-point-functions #'codeium-completion-at-point)
;;     :config
;;     (setq use-dialog-box nil)
;;     (setq codeium-mode-line-enable
;;         (lambda (api) (not (memq api '(CancelRequest Heartbeat AcceptCompletion)))))
;;     (add-to-list 'mode-line-format '(:eval (car-safe codeium-mode-line)) t)
;;     (setq codeium-api-enabled
;;         (lambda (api)
;;             (memq api '(GetCompletions Heartbeat CancelRequest GetAuthToken RegisterUser auth-redirect AcceptCompletion))))
;;     (setq codeium-show-preview t)
;;     (run-with-idle-timer 0.5 nil #'codeium-completion-at-point)))

(use-package orderless
  :ensure t
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion))))
  :custom
  (completion-styles '(orderless)))

(use-package emacs
  :init
  (setq completion-cycle-threshold 5)
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 4)
  (setq-default standard-indent 4)
  (add-hook 'prog-mode-hook
            (lambda ()
              (setq indent-tabs-mode nil)
              (setq tab-width 4)
              (setq standard-indent 4)))
  (add-hook 'text-mode-hook
            (lambda ()
              (setq indent-tabs-mode nil)
              (setq tab-width 4)
              (setq standard-indent 4))))

(use-package wgrep
  :ensure t
  :bind ( :map grep-mode-map
          ("e" . wgrep-change-to-wgrep-mode)
          ("C-x C-q" . wgrep-change-to-wgrep-mode)
          ("C-c C-c" . wgrep-finish-edit)))

;; LSP - disabled (uncomment to re-enable)
;; (use-package lsp-mode
;;   :init (setq lsp-keymap-prefix "C-c l")
;;   :hook ((python-mode . lsp)
;;          (python-ts-mode . lsp)
;;          (yaml-mode . lsp))
;;   :commands lsp)
;; (use-package lsp-pyright
;;   :after lsp-mode
;;   :hook ((python-mode . (lambda () (require 'lsp-pyright)))
;;          (python-ts-mode . (lambda () (require 'lsp-pyright)))))

(use-package vterm
  :ensure t
  :custom
  (vterm-always-compile-module t))

(use-package cmake-mode
  :ensure t)

(use-package treemacs
  :ensure t
  :bind (:map global-map ("C-c C-." . treemacs)))

;;;;;;;;;;;;;;;;
;; Keybindings ;;
;;;;;;;;;;;;;;;;

;; Window management
(autoload 'swap-windows "swap-windows" "Swap 2 windows")
(global-set-key (kbd "C-c s") 'swap-windows)
(global-set-key (kbd "C-c C-v") 'browse-url)
(global-set-key (kbd "C-x O") 'previous-multiframe-window)
(global-set-key (kbd "C-.") 'next-multiframe-window)
(global-set-key (kbd "C-,") 'previous-multiframe-window)
(global-set-key (kbd "M-e") 'windmove-up)
(global-set-key (kbd "M-n") 'windmove-down)
(global-set-key (kbd "M-h") 'windmove-left)
(global-set-key (kbd "M-i") 'windmove-right)

;; Buffers & navigation
(global-set-key (kbd "C-c n") 'next-buffer)
(global-set-key (kbd "C-c e") 'previous-buffer)
(global-set-key (kbd "C-x K") 'recentf-open-most-recent-file)
(global-set-key (kbd "C-x C-r") 'consult-recent-file)
(global-set-key (kbd "C-<return>") 'vterm)

;; Code folding
(global-set-key (kbd "C-c C-c") 'hs-hide-block)
(global-set-key (kbd "C-c c") 'hs-show-block)

;; Multiple cursors
(require 'multiple-cursors)
(global-set-key (kbd "C-c C-SPC") 'mc/edit-lines)
(global-set-key (kbd "M-SPC") 'mc/edit-lines)
(global-set-key (kbd "C-c C-n") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-a") 'mc/mark-all-like-this)

;;;;;;;;;;;;
;; Consult ;;
;;;;;;;;;;;;

(use-package consult
  :ensure t
  :bind (("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ("C-x M-:" . consult-complex-command)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("C-x t b" . consult-buffer-other-tab)
         ("C-x r b" . consult-bookmark)
         ("C-x p b" . consult-project-buffer)
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)
         ("C-M-#" . consult-register)
         ("M-y" . consult-yank-pop)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ("M-s d" . consult-find)
         ("M-s c" . consult-locate)
         ("M-s M-s" . consult-grep)
         ("C-c C-s" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         :map minibuffer-local-map
         ("M-s" . consult-history)
         ("M-r" . consult-history))
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   :preview-key '(:debounce 0.4 any))
  (setq consult-narrow-key "<"))

;;;;;;;;;;;
;; Macros ;;
;;;;;;;;;;;

(defun merge-request ()
  (interactive)
  (insert "$")
  (other-window 1)
  (tab-to-tab-stop)
  (search-forward "https")
  (browse-url (thing-at-point 'url)))
(global-set-key (kbd "<f5>") 'merge-request)

;;;;;;;;;;;;;;;;;;;;;
;; Eshell env vars  ;;
;;;;;;;;;;;;;;;;;;;;;

(setenv "OKTA_TEAM" "devops-sso")
(setenv "GOPATH" (expand-file-name "~/go-projects"))
(setenv "PATH" (concat (getenv "PATH") ":" (expand-file-name "~/go-projects/bin")))
(setenv "LS_OPTIONS" "--color=auto")

(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Custom (auto-generated) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
 '(package-selected-packages
   '(ace-window cfrs cmake-mode company consult exec-path-from-shell
                flycheck helm ht hydra idle-highlight-mode kubernetes
                marginalia multiple-cursors nadvice neotree orderless
                pfuture regex-tool terraform-mode treemacs vertico
                vterm wgrep xclip yaml-mode)))

(custom-set-faces)

;;; .emacs ends here
