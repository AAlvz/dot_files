;;; init --- Alfonso's Emacs -*- lexical-binding: t; -*-

;; Start server so emacsclient can connect to this instance
(require 'server)
(unless (server-running-p)
  (server-start))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize packages   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'package)

(setq package-archives '(("gnu"    . "https://elpa.gnu.org/packages/")
                          ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                          ("melpa"  . "https://melpa.org/packages/")))

(setq package-archive-priorities '(("melpa" . 10)
                                    ("gnu" . 5)
                                    ("nongnu" . 3)))

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

;; Mouse & scrolling on a text terminal (Windows Terminal, xterm, ...).
;; A tty never sends `wheel-up'/`wheel-down' -- those are GUI-only event
;; names.  xt-mouse turns wheel ticks into `mouse-4'/`mouse-5', so that is
;; what has to be bound (see the vterm block below).
;;
;; Emacs also asks the terminal to report *every* mouse motion (\e[?1003h).
;; That floods Emacs with events, and terminals that set the motion bit on
;; wheel reports make Emacs decode a wheel tick as `mouse-movement', which is
;; discarded -- the wheel then does nothing at all.  Ask for 1002 instead
;; (motion only while a button is held); drag-select still works.  The advice
;; has to be installed before the mode sends the sequence to the terminal.
(defun my/xterm-mouse-no-motion-tracking (seq)
  "Swap any-motion tracking (1003) for button-motion tracking (1002) in SEQ."
  (replace-regexp-in-string "\\[\\?1003" "[?1002" seq))
(advice-add 'xterm-mouse-tracking-enable-sequence :filter-return
            #'my/xterm-mouse-no-motion-tracking)
(advice-add 'xterm-mouse-tracking-disable-sequence :filter-return
            #'my/xterm-mouse-no-motion-tracking)
(xterm-mouse-mode 1)
;; Set through customize so mwheel rebuilds its key bindings for the new value.
(customize-set-variable 'mouse-wheel-scroll-amount '(3 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)
(setq scroll-conservatively 101)
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
;; `setq-default', NOT `setq'.  `major-mode' is permanently buffer-local, so a
;; plain setq here sets it for whatever buffer happens to be current -- and when
;; this file is reloaded with M-x load-file from inside a vterm, that is the
;; vterm buffer.  Its major-mode then reads as `text-mode' while everything else
;; about it stays a terminal, and `vterm-copy-mode' refuses to start with
;; "You cannot enable vterm-copy-mode outside vterm buffers", which takes every
;; scrollback command down with it.
(setq-default major-mode 'text-mode)
(add-hook 'find-file-hook 'normal-mode)
(show-paren-mode 1)
(setq column-number-mode t)
;; The vterm-mode hook below turns line numbers off, but only when a vterm
;; buffer is created.  Reloading this file re-runs the globalized mode, which
;; switches them back on in terminals that are already open.  Keep the global
;; mode out of vterm buffers entirely instead.
(defun my/line-numbers-not-in-vterm ()
  "Return nil in vterm buffers, so the globalized mode skips them."
  (not (derived-mode-p 'vterm-mode)))
(advice-add 'display-line-numbers--turn-on :before-while
            #'my/line-numbers-not-in-vterm)
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

;; WSL clipboard bridge - self-activating, inert on macOS and native Linux.
;; Under WSLg the xclip setup above already reaches the Windows clipboard; these
;; helpers are the fallback for WSL without WSLg, or before xclip is installed.
(defconst my/wsl-p
  (and (eq system-type 'gnu/linux)
       (or (getenv "WSL_DISTRO_NAME")
           (and (file-readable-p "/proc/version")
                (with-temp-buffer
                  (insert-file-contents "/proc/version")
                  (string-match-p "[Mm]icrosoft" (buffer-string)))))
       t)
  "Non-nil when running under the Windows Subsystem for Linux.")

(when my/wsl-p
  (defun wsl-copy (start end)
    "Copy region between START and END to the Windows clipboard via clip.exe."
    (interactive "r")
    (copy-region-as-kill start end)
    ;; Send to clip.exe without popping up a *Shell Command Output* window.
    (call-process-region start end "clip.exe")
    (message "Copied to Windows clipboard"))

  (defun wsl-paste-from-clipboard ()
    "Insert the Windows clipboard contents, stripping CRLF line endings."
    (interactive)
    (insert (replace-regexp-in-string
             "\r" ""
             (shell-command-to-string
              "powershell.exe -NoProfile -Command Get-Clipboard"))))

  (global-set-key (kbd "C-c x") #'wsl-copy)
  (global-set-key (kbd "C-c v") #'wsl-paste-from-clipboard))

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

;; Idle highlight is configured with the other `use-package' forms below.  A
;; bare `require' here would run before the package is installed, so a fresh
;; machine dies on this line during its first `emacs' run.

;;;;;;;;;;;;;;;;;;;
;; Use-packages  ;;
;;;;;;;;;;;;;;;;;;;

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

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

;; `:hook' makes use-package defer the package, so the face has to be set
;; through `:custom-face' rather than `set-face-attribute' -- the latter needs
;; the face to exist already, and it does not until the package loads.
(use-package idle-highlight-mode
  :ensure t
  :init
  (setq idle-highlight-idle-time 0.2)
  (add-hook 'after-change-major-mode-hook #'idle-highlight-mode)
  :custom-face
  (idle-highlight ((t (:background "#FFFFCC" :foreground "#333333"))))
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

(defun my/vterm-kill-ring-pop ()
  "Browse kill ring with completing-read and send selection to vterm."
  (interactive)
  (let ((text (completing-read "Kill ring: "
                               (cl-remove-duplicates kill-ring :test #'equal :from-end t)
                               nil t)))
    (when (and text (not (string-empty-p text)))
      (vterm-send-string text))))

;; Browsing vterm scrollback.  Every obvious route out of the box is a dead
;; end: vterm forwards C-v, M-v and PageUp straight to the shell, and Windows
;; Terminal swallows Shift-PageUp for its own scrollback, so it never reaches
;; Emacs.  Worse, plain scrolling looks broken even when it works -- vterm
;; moves point back to the cursor on every byte of output, so a redrawing TUI
;; (Claude Code, htop, a spinner) yanks the window back to the prompt at once.
;;
;; `vterm-copy-mode' is the way out: it detaches the buffer from the live
;; terminal, so the view stays where it is put.  Scroll back and we enter it
;; automatically; scroll forward past the end and we leave it again.
(defun my/vterm-scroll-back (&optional lines)
  "Scroll LINES back through vterm scrollback, a screenful by default."
  (interactive)
  (unless (bound-and-true-p vterm-copy-mode)
    (vterm-copy-mode 1))
  (condition-case nil
      (scroll-down-command lines)
    (beginning-of-buffer (goto-char (point-min)))))

(defun my/vterm-scroll-forward (&optional lines)
  "Scroll LINES forward, reattaching to the live terminal at the prompt."
  (interactive)
  (condition-case nil
      (scroll-up-command lines)
    (end-of-buffer
     (goto-char (point-max))
     (when (bound-and-true-p vterm-copy-mode)
       (vterm-copy-mode -1)))))

(defun my/vterm-wheel-up ()
  "Scroll back three lines, for one tick of the mouse wheel."
  (interactive)
  (my/vterm-scroll-back 3))

(defun my/vterm-wheel-down ()
  "Scroll forward three lines, for one tick of the mouse wheel."
  (interactive)
  (my/vterm-scroll-forward 3))

;; `vterm-copy-mode' alone is not enough.  All it does to hold the screen
;; still is send XOFF down the pty (`vterm-send-stop'), and a program in raw
;; mode -- Claude Code, htop, anything full-screen -- has IXON off, so XOFF
;; is never honoured.  Output keeps arriving, `vterm--filter' keeps calling
;; `vterm--update', and every redraw drags point back to the cursor.  That is
;; why scrolling looked dead even inside copy mode.
;;
;; Nothing upstream guards the redraw, so put the window back where it was
;; after each one while copy mode is on.  Output still streams into the
;; buffer underneath; the view just stops chasing it.
(defun my/vterm-hold-view-during-redraw (orig buffer)
  "Call ORIG on BUFFER, restoring the scroll position if browsing scrollback."
  (if (not (and (buffer-live-p buffer)
                (buffer-local-value 'vterm-copy-mode buffer)))
      (funcall orig buffer)
    (let ((pt (with-current-buffer buffer (point)))
          (starts (mapcar (lambda (w) (cons w (window-start w)))
                          (get-buffer-window-list buffer nil t))))
      (funcall orig buffer)
      (with-current-buffer buffer
        (setq pt (min pt (point-max)))
        (goto-char pt)
        (pcase-dolist (`(,win . ,start) starts)
          (when (window-live-p win)
            (set-window-start win (min start (point-max)) t)
            (set-window-point win pt)))))))
(advice-add 'vterm--delayed-redraw :around #'my/vterm-hold-view-during-redraw)

(use-package vterm
  :ensure t
  :custom
  (vterm-always-compile-module t)
  (vterm-max-scrollback 100000)
  :hook
  (vterm-mode . (lambda () (display-line-numbers-mode -1)))
  :config
  (dotimes (i 10)
    (define-key vterm-mode-map (kbd (format "M-%d" i)) nil))
  (define-key vterm-mode-map (kbd "M-TAB") nil)
  (define-key vterm-mode-map (kbd "M-y") #'my/vterm-kill-ring-pop)
  (define-key vterm-mode-map (kbd "C-g") 'vterm-send-escape)
  ;; Keyboard: Alt-PageUp/PageDown.  Windows Terminal leaves these alone,
  ;; unlike Shift-PageUp, and vterm does not forward them to the shell.
  (define-key vterm-mode-map (kbd "M-<prior>") #'my/vterm-scroll-back)
  (define-key vterm-mode-map (kbd "M-<next>")  #'my/vterm-scroll-forward)
  (define-key vterm-mode-map (kbd "S-<prior>") #'my/vterm-scroll-back)
  (define-key vterm-mode-map (kbd "S-<next>")  #'my/vterm-scroll-forward)
  ;; Wheel: mouse-4/mouse-5 on a tty, wheel-up/wheel-down under a GUI.
  (define-key vterm-mode-map (kbd "<mouse-4>")    #'my/vterm-wheel-up)
  (define-key vterm-mode-map (kbd "<mouse-5>")    #'my/vterm-wheel-down)
  (define-key vterm-mode-map (kbd "<wheel-up>")   #'my/vterm-wheel-up)
  (define-key vterm-mode-map (kbd "<wheel-down>") #'my/vterm-wheel-down)
  ;; The same keys have to keep working once copy mode is on, or scrolling
  ;; back would be a one-way trip.  `q' leaves copy mode without copying.
  (define-key vterm-copy-mode-map (kbd "M-<prior>")   #'my/vterm-scroll-back)
  (define-key vterm-copy-mode-map (kbd "M-<next>")    #'my/vterm-scroll-forward)
  (define-key vterm-copy-mode-map (kbd "S-<prior>")   #'my/vterm-scroll-back)
  (define-key vterm-copy-mode-map (kbd "S-<next>")    #'my/vterm-scroll-forward)
  (define-key vterm-copy-mode-map (kbd "<mouse-4>")   #'my/vterm-wheel-up)
  (define-key vterm-copy-mode-map (kbd "<mouse-5>")   #'my/vterm-wheel-down)
  (define-key vterm-copy-mode-map (kbd "<wheel-up>")  #'my/vterm-wheel-up)
  (define-key vterm-copy-mode-map (kbd "<wheel-down>") #'my/vterm-wheel-down)
  (define-key vterm-copy-mode-map (kbd "q") #'vterm-copy-mode))

(use-package cmake-mode
  :ensure t)

(use-package treemacs
  :ensure t
  :bind (:map global-map ("C-c C-." . treemacs)))

(tab-bar-mode 1)
(setq tab-bar-tab-hints t)
(setq tab-bar-close-button-show nil)
(setq tab-bar-new-tab-to 'rightmost)

(defun tab-bar-select-or-create-tab (&optional tab-number)
  "Switch to tab TAB-NUMBER, creating tabs up to that number if needed."
  (interactive
   (list (let ((key (event-basic-type last-command-event)))
           (if (and (characterp key) (>= key ?0) (<= key ?9))
               (- key ?0)
             0))))
  (let ((tab-count (length (tab-bar-tabs))))
    (if (<= tab-number tab-count)
        (tab-bar-select-tab tab-number)
      (dotimes (_ (- tab-number tab-count))
        (tab-bar-new-tab))
      (tab-bar-select-tab tab-number))))

(dotimes (i 9)
  (global-set-key (kbd (format "M-%d" (1+ i)))
                  'tab-bar-select-or-create-tab))
(global-set-key (kbd "M-0") 'tab-bar-close-tab)
(global-set-key (kbd "M-TAB") 'tab-recent)

;;;;;;;;;;;;;;;;
;; Keybindings ;;
;;;;;;;;;;;;;;;;

;; Window management
(autoload 'swap-windows "swap-windows" "Swap 2 windows")
(global-set-key (kbd "C-c s") 'swap-windows)
(defun browse-url-smart ()
  "Open URL at point, or extract one from clipboard."
  (interactive)
  (let ((url-at-point (thing-at-point 'url t)))
    (cond
     (url-at-point (browse-url url-at-point))
     (t (let* ((raw (string-trim (or (gui-get-selection 'CLIPBOARD)
                                     (current-kill 0 t) "")))
               (url (when (string-match "https?://[^ \t\n\r\"<>]*[^ \t\n\r\"<>().,;]" raw)
                      (match-string 0 raw))))
          (if url
              (browse-url url)
            (message "No URL found at point or in clipboard")))))))
(global-set-key (kbd "C-c C-v") 'browse-url-smart)
(global-set-key (kbd "C-x O") 'previous-multiframe-window)
(global-set-key (kbd "M-e") 'windmove-up)
(global-set-key (kbd "M-n") 'windmove-down)
(global-set-key (kbd "M-h") 'windmove-left)
(global-set-key (kbd "M-i") 'windmove-right)

;; Buffers & navigation
(global-set-key (kbd "C-c n") 'next-buffer)
(global-set-key (kbd "C-c p") 'previous-buffer)
(global-set-key (kbd "C-c e") 'previous-buffer)
(global-set-key (kbd "C-x K") 'recentf-open-most-recent-file)
(global-set-key (kbd "C-x C-r") 'consult-recent-file)
;; Text terminals cannot encode most Ctrl/Shift chords: C-<return> and RET both
;; arrive as a bare CR, and C-< has no encoding at all. Terminals that support
;; xterm's modifyOtherKeys send "ESC [ 27 ; <modifier> ; <keycode> ~" instead,
;; so decode those back into real Emacs key events here.
;;
;; This stays cross-platform: a terminal that never emits these sequences simply
;; never triggers the entries, so the block is inert on macOS and native Linux.
;; The emitting side is configured per terminal emulator, not per dotfile --
;; on Windows Terminal see User.sendInput.* in its settings.json.
(defvar my/tty-key-sequences
  '(("\e[27;5;13~" . "C-<return>")   ; ctrl+enter  -> vterm
    ("\e[27;6;44~" . "C-<"))         ; ctrl+shift+, -> mc/mark-previous-like-this
  "Alist of modifyOtherKeys escape sequences to the key each should produce.")

(defun my/tty-setup-extra-keys ()
  "Teach text terminals the key sequences GUI Emacs gets for free."
  (dolist (pair my/tty-key-sequences)
    (define-key input-decode-map (car pair) (kbd (cdr pair)))))

;; tty-setup-hook runs once per text terminal, which is what emacsclient needs:
;; input-decode-map is terminal-local, so a global setq would only reach the
;; first frame.
(add-hook 'tty-setup-hook #'my/tty-setup-extra-keys)

(global-set-key (kbd "C-<return>") 'vterm)

;; Code folding
(global-set-key (kbd "C-c C-c") 'hs-hide-block)
(global-set-key (kbd "C-c c") 'hs-show-block)

;; Multiple cursors.  `use-package' rather than a bare `require': the package
;; was only ever listed in `package-selected-packages', so a machine that had
;; not run `package-install-selected-packages' by hand died on the require.
(use-package multiple-cursors
  :ensure t)
(global-set-key (kbd "C-c C-SPC") 'mc/edit-lines)
(global-set-key (kbd "M-SPC") 'mc/edit-lines)
(global-set-key (kbd "C-c C-n") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-a") 'mc/mark-all-like-this)
;; Terminal-safe fallbacks for chords a terminal may not deliver. C-< needs the
;; modifyOtherKeys setup above; Alt+Tab never reaches Emacs on Windows at all,
;; since the OS claims it before the terminal sees it.
(global-set-key (kbd "C-c C-p") 'mc/mark-previous-like-this) ; = C-<
(global-set-key (kbd "C-c TAB") 'tab-recent)                 ; = M-TAB

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
         ("M-s d" . consult-fd)
         ("M-s D" . consult-find)
         ("M-s c" . consult-locate)
         ("M-s M-s" . consult-ripgrep)
         ("C-c C-s" . consult-ripgrep)
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

(use-package embark
  :ensure t
  :bind (("C-." . embark-act)
         ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :ensure t
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package avy
  :ensure t
  :bind ("C-," . avy-goto-char-timer))

(use-package which-key
  :ensure t
  :config (which-key-mode))

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
  :custom
  (exec-path-from-shell-arguments '("-l"))
  :config
  (exec-path-from-shell-initialize))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Custom (auto-generated) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(avy cmake-mode company consult embark embark-consult
         exec-path-from-shell flycheck idle-highlight-mode kubernetes
         magit marginalia multiple-cursors orderless treemacs vertico
         vterm wgrep which-key xclip)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;; .emacs ends here
