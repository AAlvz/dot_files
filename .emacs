;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; Initialize packages ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'package)

;;; Code:
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                          ("melpa" . "https://melpa.org/packages/")))
                          ;; ("marmalade" . "http://marmalade-repo.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))

;; Codeium - only load if directory exists
(when (file-directory-p "~/.emacs.d/codeium.el/")
  (add-to-list 'load-path "~/.emacs.d/codeium.el/"))
(add-to-list 'load-path "~/.emacs.d/lisp/")
;; (load "corfu-terminal")
(load "popon")
(load "subr-x")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; ENABLE USEFUL DEFAULT FUNCTIONS. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (load-theme 'tango-dark)
;; (load-theme 'wombat)
(windmove-default-keybindings)
(xterm-mouse-mode)
(load-theme 'misterioso) ;; SET DEFAULT THEME
(recentf-mode 1) ;; List of recently opened files
(setq history-length 25) ;; History for commands. Also M-x
(savehist-mode 1)
(save-place-mode 1) ;; Open file in the position you left it
(put 'set-goal-column 'disabled nil) ;; CxCn shortcut to go down or up to the same column
(winner-mode 1) ;; Winner mode to remember past windows arrangements
(setq major-mode 'text-mode);; Select the best mode for type of file
(add-hook 'find-file-hook 'normal-mode)
;; flycheck is enabled via use-package below
;; company-mode is enabled via use-package below
(show-paren-mode 1);; Visualize where parenthesis open and close
(setq column-number-mode t);; Show Line row Number
(global-display-line-numbers-mode)
(electric-pair-mode 1);; Auto insert closing bracket
(electric-indent-mode -1);; Disable electir indent mode by default
;; (unless (display-graphic-p);; IMPORTANT. DO NOT REMOVE. SHOW POPUP COMLPETITION.
;;   (corfu-terminal-mode +1))
;; (setq corfu-auto t ;; Enable auto completion and configure quitting
;;       corfu-quit-no-match 'separator) ;; or t
;; (setq-local corfu-auto        t
;;             corfu-auto-delay  0.2 ;; TOO SMALL - NOT RECOMMENDED
;;             corfu-auto-prefix 0.9 ;; TOO SMALL - NOT RECOMMENDED
;;             completion-styles '(basic))
(with-eval-after-load 'consult
  (setq consult-buffer-completion-style 'orderless))
(setq require-final-newline t) ;; Silently ensure newline at end of file
(require 'whitespace) ;;Highlight characters over 80 and linees with spaces and tabs probably
(setq whitespace-style '(face empty tabs lines-tail trailing))
(global-whitespace-mode t)
;; X11 clipboard integration - copy with M-w pastes to system clipboard
(setq select-enable-clipboard t)  ;; Use CLIPBOARD (Ctrl+V paste)
(setq select-enable-primary t)    ;; Also use PRIMARY (middle-click paste)
(setq x-select-enable-clipboard-manager t) ;; Work with clipboard managers

;; For terminal mode (-nw): use xclip package to access system clipboard
(use-package xclip
  :ensure t
  :config
  (xclip-mode 1))

(setq backup-directory-alist `(("." . "~/.emacs_saves"))) ;; Set Backups directory
(setq version-control t     ;; Use version numbers for backups.
      kept-new-versions 10  ;; Number of newest versions to keep.
      kept-old-versions 5   ;; Number of oldest versions to keep.
      delete-old-versions t ;; Don't ask to delete excess backup versions.
      backup-by-copying t)  ;; Copy all files, don't rename them.
(put 'upcase-region 'disabled nil)
(add-hook 'prog-mode-hook #'hs-minor-mode) ;; Always enable hs-minor-mode. Hide/show blocks
(require 'idle-highlight-mode) ;; Enable idle-highlight mode by default in all buffers

(add-hook 'after-change-major-mode-hook 'idle-highlight-mode)
(set-face-attribute 'idle-highlight nil :background "#FFFFCC" :foreground "#333333");; Define custom colors for idle-highlight mode with less intense colors
(defun my-eshell-prompt ();; Show time at the beginning of shell prompt
  (concat (format-time-string "[%H:%M:%S] " (current-time)) (eshell/pwd) " $ "))
(setq eshell-prompt-function #'my-eshell-prompt)

;;;;;;;;;;;;;;;;;;;;
;; CUSTOM CONFIGS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package company
  ;; Instructions
  ;; Completion will start automatically after you type a few letters. Use C-n and C-p to select, <return> to complete or <tab> to complete the common part. Search through the completions with C-s, C-r and C-o. Press M-(digit) to quickly complete with one of the first 10 candidates.

  ;; Type M-x company-complete to initiate completion manually. Bind this command to a key combination of your choice (this is optional).
    :defer 0.1
    :config
    (global-company-mode t)
    (setq-default
        company-idle-delay 0.05
        company-require-match nil
        company-minimum-prefix-length 0

        ;; get only preview
        company-frontends '(company-preview-frontend)
        ;; also get a drop down
        company-frontends '(company-pseudo-tooltip-frontend company-preview-frontend)
        ))
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))
(use-package idle-highlight-mode ;; Idle highlight
  :config (setq idle-highlight-idle-time 0.2)
  :hook ((prog-mode text-mode) . idle-highlight-mode)
)
(use-package savehist ;; Persist history over Emacs restarts. Vertico sorts by history position.
  :init
  (savehist-mode)
)
(use-package vertico
  :init
  (vertico-mode)
  ;; (setq vertico-scroll-margin 0)  ;; Different scroll margin
  ;; (setq vertico-count 20)   ;; Show more candidates
)
(use-package marginalia ;; Enable rich annotations using the Marginalia package
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode)
)
;; Codeium - only load if installed
;; To install: git clone https://github.com/Exafunction/codeium.el ~/.emacs.d/codeium.el
(when (file-directory-p "~/.emacs.d/codeium.el/")
  (use-package codeium
    :init
    (add-to-list 'completion-at-point-functions #'codeium-completion-at-point)
    :config
    (setq use-dialog-box nil)
    (setq codeium-mode-line-enable
        (lambda (api) (not (memq api '(CancelRequest Heartbeat AcceptCompletion)))))
    (add-to-list 'mode-line-format '(:eval (car-safe codeium-mode-line)) t)
    (setq codeium-api-enabled
        (lambda (api)
            (memq api '(GetCompletions Heartbeat CancelRequest GetAuthToken RegisterUser auth-redirect AcceptCompletion))))
    (setq codeium-show-preview t)
    (run-with-idle-timer 0.5 nil #'codeium-completion-at-point)))
(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
	;; read-buffer-completion-ignore-case t
	;; consult-buffer-completion-style 'orderless
        completion-category-overrides '((file (styles basic partial-completion))))
 :custom
  (completion-styles '(orderless))
  ;; (orderless-matching-styles '(orderless-regexp))
)
(use-package emacs
  :init
  (setq completion-cycle-threshold 5)
  ;; (setq tab-always-indent 'complete)
)
;; (use-package corfu
;;   ;; Optional customizations
;;   ;; :custom
;;   ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
;;   ;; (corfu-auto nil)                 ;; Enable auto completion
;;   ;; (corfu-separator ?\s)          ;; Orderless field separator
;;   ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
;;   ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
;;   ;; (corfu-preview-current nil)    ;; Disable current candidate preview
;;   ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
;;   ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
;;   ;; (corfu-scroll-margin 5)        ;; Use scroll margin

;;   ;; Enable Corfu only for certain modes.
;;   ;; :hook ((prog-mode . corfu-mode)
;;   ;;        (shell-mode . corfu-mode)
;;   ;;        (eshell-mode . corfu-mode))

;;   ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
;;   ;; be used globally (M-/).  See also the customization variable
;;   ;; `global-corfu-modes' to exclude certain modes.
;;   :init
;;   (global-corfu-mode))
(use-package wgrep
  :ensure t
  :bind ( :map grep-mode-map
          ("e" . wgrep-change-to-wgrep-mode)
          ("C-x C-q" . wgrep-change-to-wgrep-mode)
          ("C-c C-c" . wgrep-finish-edit))
)
(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (python-mode . lsp)
	 (yaml-mode . lsp))
  :commands lsp)
(use-package treemacs
  :ensure t
  :bind
  (:map global-map
        ("C-c C-." . treemacs)
	("C-." . treemacs-select-window))
  :config
  (setq treemacs-is-never-other-window t))



(autoload 'swap-windows "swap-windows" "Swap 2 windows");; Setup Swap Windows
(global-set-key (kbd "C-c s") 'swap-windows)
(global-set-key (kbd "C-c C-v") 'browse-url)
;; (global-set-key (kbd "C-.") 'neotree-refresh)


;; ;;;;;;;;;;;;;;;;;;;;;
;; ;; ;; MAC COMMANDS ;;
;; ;;;;;;;;;;;;;;;;;;;;;
;; ;; ;; Copy/Paste to clipboard OSX
;; (defun copy-from-osx ()
;;   (shell-command-to-string "pbpaste"))
;; (defun paste-to-osx (text &optional push)
;;   (let ((process-connection-type nil))
;;     (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
;;       (process-send-string proc text)
;;       (process-send-eof proc))))
;; (setq interprogram-cut-function 'paste-to-osx)
;; (setq interprogram-paste-function 'copy-from-osx)

;; ;; ;; ;;; UPDATED
;; ;; ;; (defun copy-to-macos-clipboard (text &optional push)
;; ;; ;;   (let ((process-connection-type nil))
;; ;; ;;     (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
;; ;; ;;       (process-send-string proc text)
;; ;; ;;       (process-send-eof proc))
;; ;; ;;     (setq kill-ring (cons text kill-ring))))
;; ;; ;;
;; ;; ;; (defun paste-from-macos-clipboard ()
;; ;; ;;   (shell-command-to-string "pbpaste"))
;; ;; ;;
;; ;; ;; (setq interprogram-cut-function 'copy-to-macos-clipboard)
;; ;; ;;(setq interprogram-paste-function 'paste-from-macos-clipboard)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(codeium/metadata/api_key "130eeb3a-3876-4c8b-914c-390437a120c0")
 '(package-selected-packages
   '(treemacs vterm markdown-ts-mode markdown-preview-mode impatient-showdown company lsp-mode flycheck-yamllint flycheck regex-tool yaml-mode wgrep vertico terraform-mode pfuture orderless neotree nadvice multiple-cursors markdown-mode marginalia magit idle-highlight-mode hydra ht helm corfu-candidate-overlay consult cfrs ace-window)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;;;;;;;;;;;;;;;;;;;
;; ;; KEYBINDINGS ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; DEFAULTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; GO TO MATCHING PARENTHESIS. (overlay. already exists)
;;;;;;;;;;;;;;;;;
;; (global-set-key (kbd "C-M-f") 'forward-sexp)  ; Bind forward-sexp to C-c f
;; (global-set-key (kbd "C-M-b") 'backward-sexp) ; Bind backward-sexp to C-c b
;; (global-set-key (kbd "C-M-n") 'forward-sexp)  ; Bind forward-sexp to C-c f
;; (global-set-key (kbd "C-M-p") 'backward-sexp) ; Bind backward-sexp to C-c b

;; UPPERCASE REGION
;; (global-set-key (kbd "C-x u") 'upcase-region)
;; (global-set-key (kbd "C-x l") 'lowercase-region)

;; CUSTOM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "C-c C-c") 'hs-hide-block);; Shortcut to hide blocks
(global-set-key (kbd "C-c c") 'hs-show-block);; Shortcut to show blocks
;; (global-set-key (kbd "C-x k") 'kill-buffer-and-window) ;; kill buffer no prompt
(global-set-key (kbd "C-x K") 'recentf-open-most-recent-file) ;; Open last killed file
(global-set-key (kbd "C-x O") 'previous-multiframe-window) ;; Switch to previous window
;;(global-set-key (kbd "<C-tab>") 'next-buffer) ;; Switch to previous window
;; (global-set-key (kbd "C-<tab>") 'next-buffer)
(global-set-key (kbd "C-<return>") 'shell) ;; Switch to previous window
(global-set-key (kbd "C-x C-r") 'consult-recent-file) ;; Consult recent file

(global-set-key (kbd "C-c n") 'next-buffer) ;; move to next buffer
(global-set-key (kbd "C-c e") 'previous-buffer) ;; move to prev buffer
(global-set-key (kbd "M-e") 'windmove-up) ;; move to prev buffer
(global-set-key (kbd "M-n") 'windmove-down) ;; move to prev buffer
(global-set-key (kbd "M-h") 'windmove-left) ;; move to prev buffer
(global-set-key (kbd "M-i") 'windmove-right) ;; move to prev buffer


;; multiple cursors
(require 'multiple-cursors)
(global-set-key (kbd "C-c C-SPC") 'mc/edit-lines)
(global-set-key (kbd "M-SPC") 'mc/edit-lines)
(global-set-key (kbd "C-c C-n") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-a") 'mc/mark-all-like-this)

;;;;;;;;;;;;;
;; CONSULT ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Example configuration for Consult
(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s M-s" . consult-grep)                ;; Default: "M-s g"
         ("C-c C-s" . consult-grep)                ;; Default: "M-s g"
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ;; ("C-s" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.

  :config

  ;; TEST
  ;; (setq consult-buffer-completion-style 'orderless)
  ;; (setq consult-buffer-customize (lambda (input)
  ;;                                  (list :orderless input)))

  ;; (setq consult-buffer-customize (lambda (input)
  ;;                                  (list :orderless input :regexp t)))


  ;; ;; Optionally configure preview. The default value
  ;; ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))

  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  ;;;; 4. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 5. No project support
  ;; (setq consult-project-function nil)
)

;;; COnSULT END

;;; MACROS
(defun merge-request ()
  (interactive)
  (insert "$")
  (other-window 1)
  (tab-to-tab-stop)
  (search-forward "https")
  (browse-url (thing-at-point 'url)))

(global-set-key (kbd "<f5>") 'merge-request)
;; (global-set-key (kbd "C-c m r") 'swap-windows)
;; (fset 'my-macro
;;    [?\C-x ?o ?$ tab ?\C-s])
;;; .emacs ends here
