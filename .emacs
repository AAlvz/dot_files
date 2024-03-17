;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; Initialize packages ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'package)

(setq package-archives '(("ELPA" . "http://tromey.com/elpa/")
                          ("gnu" . "http://elpa.gnu.org/packages/")
                          ("melpa" . "http://melpa.org/packages/")))
                          ;; ("marmalade" . "http://marmalade-repo.org/packages/")))

(package-initialize)
(unless (package-installed-p 'use-package)
(package-refresh-contents)
(package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(add-to-list 'load-path "~/.emacs.d/lisp/")

;; kill buffer no prompt
(global-set-key (kbd "C-x k") 'kill-buffer-and-window)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; ENABLE USEFUL DEFAULT FUNCTIONS. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Set Default Theme
(load-theme 'tango-dark)
;;(load-theme 'wombat)
;;(load-theme 'misterioso)
;; Avoid warning
(setq dired-use-ls-dired nil)
;; complete in shell??
(setq shell-completion-mode t)
;; List of recently opened files
(recentf-mode 1)
;; History for commands. Also M-x
(setq history-length 25)
(savehist-mode 1)
;; Open file in the position you left it
(save-place-mode 1)
;; CxCn shortcut to go down or up to the same column
(put 'set-goal-column 'disabled nil)
;; Winner mode to remember past windows arrangements
(winner-mode 1)
;; Select the best mode for type of file
(setq major-mode 'text-mode)
(add-hook 'find-file-hook 'normal-mode)
;; Visualize where parenthesis open and close
(show-paren-mode 1)
;; Show Line row Number
(setq column-number-mode t)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(display-line-numbers-mode)
;; Auto insert closing bracket
(electric-pair-mode 1)
;; Idle highlight
(use-package idle-highlight-mode
  :config (setq idle-highlight-idle-time 0.2)
  :hook ((prog-mode text-mode) . idle-highlight-mode))
;; Setup Swap Windows
(autoload 'swap-windows "swap-windows" "Swap 2 windows")
(global-set-key (kbd "C-c s") 'swap-windows)
;; Silently ensure newline at end of file
(setq require-final-newline t)
;;Highlight characters over 80 and linees with spaces and tabs probably
(require 'whitespace)
 (setq whitespace-style '(face empty tabs lines-tail trailing))
 (global-whitespace-mode t)
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
;; Always enable hs-minor-mode. Hide/show blocks
(add-hook 'prog-mode-hook #'hs-minor-mode)
;; Smex: Guidance for M-x
(require 'smex)
(global-set-key (kbd "M-x") 'smex)
;; Switch to previous window
(global-set-key (kbd "C-x O") 'previous-multiframe-window)

;; Show time at the beginning of shell prompt
(defun my-eshell-prompt ()
  (concat (format-time-string "[%H:%M:%S] " (current-time)) (eshell/pwd) " $ "))
(setq eshell-prompt-function #'my-eshell-prompt)

;;;;;;;;;;;;;;;;;;;;;
;; ;; MAC COMMANDS ;;
;;;;;;;;;;;;;;;;;;;;;
;; ;; Copy/Paste to clipboard OSX
(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))
(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))
(setq interprogram-cut-function 'paste-to-osx)
(setq interprogram-paste-function 'copy-from-osx)


;;;;;;;;;;;;;;;;;;;;
;; ;; KEYBINDINGS ;;
;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "C-c C-c") 'hs-hide-block);; Shortcut to hide blocks
(global-set-key (kbd "C-c c") 'hs-show-block);; Shortcut to show blocks


;;;;;;;;;;;;;;
;; ;; CORFU ;;
;;;;;;;;;;;;;;
;; https://github.com/minad/corfu?tab=readme-ov-file

(use-package corfu
  ;; Optional customizations
  :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  ;; (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  (corfu-preview-current t)    ;; Disable current candidate preview   (corfu-preview-current nil)
  (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin

  ;; Enable Corfu only for certain modes.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode))

;; A few more useful configurations...
(use-package emacs
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)

  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete))

;; ;; Enable auto completion and configure quitting
;; (setq corfu-auto t
;;       corfu-quit-no-match 'separator) ;; or t

(use-package corfu
  ;; TAB-and-Go customizations
  :custom
  (corfu-cycle t)           ;; Enable cycling for `corfu-next/previous'
  (corfu-preselect 'prompt) ;; Always preselect the prompt

  ;; Use TAB for cycling, default is `corfu-complete'.
  :bind
  (:map corfu-map
        ("TAB" . corfu-next)
        ([tab] . corfu-next)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous))

  :init
  (global-corfu-mode))

;; Complete in the minibuffer
(defun corfu-enable-in-minibuffer ()
  "Enable Corfu in the minibuffer."
  (when (local-variable-p 'completion-at-point-functions)
    ;; (setq-local corfu-auto nil) ;; Enable/disable auto completion
    (setq-local corfu-echo-delay nil ;; Disable automatic echo and popup
                corfu-popupinfo-delay nil)
    (corfu-mode 1)))
(add-hook 'minibuffer-setup-hook #'corfu-enable-in-minibuffer)

;; ;;   :init
;; ;;   (global-corfu-mode))

;; ;; ;; Use Dabbrev with Corfu!
;; ;; (use-package dabbrev
;; ;;   ;; Swap M-/ and C-M-/
;; ;;   :bind (("M-/" . dabbrev-completion)
;; ;;          ("C-M-/" . dabbrev-expand))
;; ;;   :config
;; ;;   (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
;; ;;   ;; Since 29.1, use `dabbrev-ignored-buffer-regexps' on older.
;; ;;   (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
;; ;;   (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode))
;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(package-selected-packages '(idle-highlight-mode corfu)))
;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  )
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(codeium/metadata/api_key "130eeb3a-3876-4c8b-914c-390437a120c0")
 '(package-selected-packages
   '(avy consult marginalia orderless vertico auto-complete smex magit terraform-mode yaml-mode json-mode idle-highlight-mode codeium.el codeium corfu)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;; codeium							    ;;
;; ;;; https://github.com/Exafunction/codeium.el?tab=readme-ov-file ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; we recommend using use-package to organize your init.el
(use-package codeium
    ;; if you use straight
    ;; :straight '(:type git :host github :repo "Exafunction/codeium.el")
    ;; otherwise, make sure that the codeium.el file is on load-path

    :init
    ;; use globally
    (add-to-list 'completion-at-point-functions #'codeium-completion-at-point)
    ;; or on a hook
    ;; (add-hook 'python-mode-hook
    ;;     (lambda ()
    ;;         (setq-local completion-at-point-functions '(codeium-completion-at-point))))

    ;; if you want multiple completion backends, use cape (https://github.com/minad/cape):
    ;; (add-hook 'python-mode-hook
    ;;     (lambda ()
    ;;         (setq-local completion-at-point-functions
    ;;             (list (cape-super-capf #'codeium-completion-at-point #'lsp-completion-at-point)))))
    ;; an async company-backend is coming soon!

    ;; codeium-completion-at-point is autoloaded, but you can
    ;; optionally set a timer, which might speed up things as the
    ;; codeium local language server takes ~0.2s to start up
    ;; (add-hook 'emacs-startup-hook
    ;;  (lambda () (run-with-timer 0.1 nil #'codeium-init)))

    ;; :defer t ;; lazy loading, if you want
    :config
    (setq use-dialog-box nil) ;; do not use popup boxes

    ;; if you don't want to use customize to save the api-key
    ;; (setq codeium/metadata/api_key "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")

    ;; get codeium status in the modeline
    (setq codeium-mode-line-enable
        (lambda (api) (not (memq api '(CancelRequest Heartbeat AcceptCompletion)))))
    (add-to-list 'mode-line-format '(:eval (car-safe codeium-mode-line)) t)
    ;; alternatively for a more extensive mode-line
    ;; (add-to-list 'mode-line-format '(-50 "" codeium-mode-line) t)

    ;; use M-x codeium-diagnose to see apis/fields that would be sent to the local language server
    (setq codeium-api-enabled
        (lambda (api)
            (memq api '(GetCompletions Heartbeat CancelRequest GetAuthToken RegisterUser auth-redirect AcceptCompletion))))
    ;; you can also set a config for a single buffer like this:
    ;; (add-hook 'python-mode-hook
    ;;     (lambda ()
    ;;         (setq-local codeium/editor_options/tab_size 4)))

    ;; You can overwrite all the codeium configs!
    ;; for example, we recommend limiting the string sent to codeium for better performance
    (defun my-codeium/document/text ()
        (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (min (+ (point) 1000) (point-max))))
    ;; if you change the text, you should also change the cursor_offset
    ;; warning: this is measured by UTF-8 encoded bytes
    (defun my-codeium/document/cursor_offset ()
        (codeium-utf8-byte-length
            (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (point))))
    (setq codeium/document/text 'my-codeium/document/text)
    (setq codeium/document/cursor_offset 'my-codeium/document/cursor_offset))

;;;;;;;;;;;;;;;;
;; ;; VERTICO ;; https://github.com/minad/vertico
;;;;;;;;;;;;;;;;

;; Enable vertico
(use-package vertico
  :init
  (vertico-mode)

  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)

  ;; Show more candidates
  ;; (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  ;; (setq vertico-cycle t)
  )

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; A few more useful configurations...
(use-package emacs
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;;;;;;;;;;;;;;;;;;;;
;; ;;; MARGINALIA ;;
;;;;;;;;;;;;;;;;;;;;
;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))
