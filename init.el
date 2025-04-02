;;; init.el --- panimacs :: alexpaniman's emacs configuration -*- lexical-binding: t -*-

;; Copyright (C) 2023 Alex Paniman

;; Author: Alex Paniman <alexpaniman@gmail.com>
;; Created: 28 May 2023

;; Keywords: panimacs emacs-configuration

(let* ((data-env "BUNDELED_EMACS_DATA")
       (data-dir (if (getenv data-env)
                     (getenv data-env)
                   (expand-file-name ".bundeled-emacs-data" (getenv "HOME")))))

  (setq no-littering-etc-directory (expand-file-name "config" data-dir))
  (setq no-littering-var-directory (expand-file-name "data" data-dir))
  )

(use-package no-littering)

;; ======================= GUI DEFAULTS =======================
(setq panimacs/font                "Fira Code"
      panimacs/variable-pitch-font "Fira Sans"
      panimacs/serif-font          "Fira Code"
      panimacs/unicode-font        "Noto Color Emoji"

      panimacs/default-font-size   20

      panimacs/default-color-theme 'doom-old-hope
      )


;; ==> Apply settings:

(setq initial-scratch-message nil
      inhibit-startup-screen    t
      inhibit-startup-message   t

      resize-mini-windows       nil

      use-short-answers         t

      default-frame-alist
      '((vertical-scroll-bars  . nil)
        (internal-border-width .   2)
        (left-fringe           .   8)
        (right-fringe          .   8)
        (tool-bar-lines        .   0)
        (menu-bar-lines        .   0))
      )

(setq frame-resize-pixelwise t
      window-resize-pixelwise t)

(setq use-dialog-box nil)
(when (bound-and-true-p tooltip-mode)
  (tooltip-mode -1))

;; Explicitly define a width to reduce the cost of on-the-fly computation
(setq-default display-line-numbers-width 3)

;; Show absolute line numbers for narrowed regions to make it easier to tell the
;; buffer is narrowed, and where you are, exactly.
(setq-default display-line-numbers-widen t)

;; Very important, disable insanely annoying bell sound!
(setq ring-bell-function 'ignore)

(defun panimacs/enable-line-numbers ()
  (interactive)
  (setq-local display-line-numbers 'visual))

(add-hook 'prog-mode-hook 'panimacs/enable-line-numbers)
(add-hook  'org-mode-hook 'panimacs/enable-line-numbers)

(setq native-comp-async-report-warnings-errors nil)

(setq mouse-wheel-scroll-amount '(2 ((shift) . hscroll))) ;; one line at a time
(setq mouse-wheel-scroll-amount-horizontal 2)

(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time

;; Don't jump & recenter after cursor gets out of the window
(setq scroll-conservatively 30)
(setq auto-window-vscroll nil)

(use-package helpful
  :after evil
  :bind
  (([remap describe-key]      . helpful-key)
   ([remap describe-command]  . helpful-command)
   ([remap describe-variable] . helpful-variable)
   ([remap describe-function] . helpful-callable))

  :config
  ;; I really want helpful to stop "helping" immediately when I type "q", PLEASE
  (evil-define-key 'normal helpful-mode-map (kbd "q") #'quit-window)
  (evil-define-key 'insert helpful-mode-map (kbd "q") #'quit-window)
  )

(use-package which-key
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.7))

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 0) ;; TODO: What to do here?
  (doom-modeline-bar-width 1)
  (doom-modeline-icon nil)
  (doom-modeline-modal nil)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-major-mode-color-icon t)
  (doom-modeline-buffer-file-name-style 'truncate-upto-project)
  (doom-modeline-buffer-state-icon t)
  (doom-modeline-buffer-modification-icon t)
  (doom-modeline-minor-modes nil)
  (doom-modeline-enable-word-count nil)
  (doom-modeline-buffer-encoding t)
  (doom-modeline-indent-info nil)
  (doom-modeline-checker-simple-format t)
  (doom-modeline-vcs-max-length 20)
  (doom-modeline-env-version t)
  (doom-modeline-irc-stylize 'identity)
  (doom-modeline-github-timer nil)
  (doom-modeline-gnus-timer nil)
  (doom-modeline-hud nil))


(setq backup-directory-alist '((".*" . "~/.trash/")))
(setq create-lockfiles nil)


(setq recentf-max-saved-items 100000)

(global-set-key (kbd "C-x o") #'other-window-prefix)


(use-package form-feed
  :init (global-form-feed-mode 1))

(defvar panimacs/font)
(defvar panimacs/variable-pitch-font)
(defvar panimacs/serif-font)
(defvar panimacs/unicode-font)

(defvar panimacs/default-font-size nil)
(defvar panimacs/font-increment 2)

(defvar panimacs/font-size nil)


(defun panimacs/init-fonts--apply-defaults (font-name)
  (font-spec :family font-name :size panimacs/font-size))

(defun panimacs/default-font-alist ()
  `((default           . ,panimacs/font               )
    (fixed-pitch       . ,panimacs/font               )
    (fixed-pitch-serif . ,panimacs/serif-font         )
    (variable-pitch    . ,panimacs/variable-pitch-font)))

(defun panimacs/init-fonts ()
  (when (null panimacs/font-size)
    (setq panimacs/font-size panimacs/default-font-size))

  (dolist (map (panimacs/default-font-alist))
    (when-let* ((face (car map)) (font-name (cdr map)))
      (set-face-attribute
       face nil :width 'normal :weight 'normal :slant 'normal
       :font (panimacs/init-fonts--apply-defaults font-name))
      )
    )

  (when (and (fboundp 'set-fontset-font)  panimacs/unicode-font)
    (set-fontset-font t 'unicode
                      (panimacs/init-fonts--apply-defaults panimacs/unicode-font)))
  )



(defun panimacs/adjust-font-size (delta)
  (setq panimacs/font-size (+ panimacs/font-size delta))
  (panimacs/init-fonts))

(defun panimacs/increase-font-size (count &optional increment)
  "Enlargens the font size across the current and child frames."
  (interactive "p")
  (panimacs/adjust-font-size (* count (or increment panimacs/font-increment))))

(defun panimacs/decrease-font-size (count &optional increment)
  "Shrinks the font size across the current and child frames."
  (interactive "p")
  (panimacs/adjust-font-size (* (- count) (or increment panimacs/font-increment))))

(defun panimacs/restore-font-size ()
  "Shrinks the font size across the current and child frames."
  (interactive)
  (panimacs/adjust-font-size (- panimacs/default-font-size panimacs/font-size)))


(global-set-key (kbd "C-M-=") #'panimacs/increase-font-size)
(global-set-key (kbd "C-M-+") #'panimacs/increase-font-size)
(global-set-key (kbd "C-M--") #'panimacs/decrease-font-size)
(global-set-key (kbd "C-M-0") #'panimacs/restore-font-size )


(let ((hook (if (daemonp) 'server-after-make-frame-hook 'after-init-hook)))
  (add-hook hook #'panimacs/init-fonts))

(defvar panimacs/default-color-theme)


(use-package doom-themes
  :init (load-theme panimacs/default-color-theme t))

;; ========================== SPLASH ==========================

;; Load and enable splash screen with panimacs name and logo
;; that will automatically show in every launched frame:
;;(require 'panimacs-splash-screen)


;; ======================= TUNE EDITING =======================

;; TODO: Work in progress, should replace evil when completed!
;; (require 'panimacs-modal-editing)

;; For now, use evil for modal editing instead:
(use-package evil
  :init
  (setq evil-want-integration        t
        evil-undo-system      'undo-fu
        evil-want-keybinding       nil

        evil-want-C-w-delete       nil

        evil-want-C-u-scroll         t
        evil-want-C-i-jump         nil
        )

  :config (evil-mode 1)
  :bind (:map evil-motion-state-map
              ("SPC" . nil)
              ("RET" . nil)
              ("TAB" . nil)

         )
  )

(use-package evil-collection
  :after evil-mode
  :ensure t
  :config
  (evil-collection-init))



(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

;; (use-package evil-tex
;;   :ensure t)

;; (add-hook 'LaTeX-mode-hook #'evil-tex-mode)
;; (add-hook 'org-mode-hook #'evil-tex-mode)


(global-set-key (kbd "C-x :") 'eval-expression)

(setq whitespace-style '(face tabs spaces space-mark tab-mark trailing indentation))
;; (custom-set-faces
;;  '(whitespace-tab ((t (:foreground "#636363")))))

;; (setq whitespace-display-mappings
;;   '((tab-mark 9 [124 9] [92 9])))


;;(use-package org-evil
;;  :config
;;  (add-hook 'org-mode-hook (lambda ()
;;                             (org-evil-mode +1)))
;;  )

(global-set-key (kbd "C-x W") 'whitespace-mode)

 ;; Enable editing history recording, saving and easy querying:
(use-package undo-fu
  :config
  (setq undo-limit            67108864 ;  64mb
        undo-strong-limit    100663296 ;  96mb
        undo-outer-limit    1006632960 ; 960mb
        )
  )


(use-package undo-fu-session
  :after undo-fu
  :init (undo-fu-session-global-mode 1)
  )


(use-package vundo
  :commands (vundo)

  :config
  ;; Take less on-screen space.
  (setq vundo-compact-display t)

  (setq vundo-glyph-alist vundo-unicode-symbols)
  (set-face-attribute 'vundo-default nil :family "JetBrains Mono")

  ;; Use `HJKL` VIM-like motion, also Home/End to jump around.
  (define-key vundo-mode-map (kbd "l"	   ) #'vundo-forward  )
  (define-key vundo-mode-map (kbd "<right>") #'vundo-forward  )
  (define-key vundo-mode-map (kbd "h"	   ) #'vundo-backward )
  (define-key vundo-mode-map (kbd "<left>" ) #'vundo-backward )
  (define-key vundo-mode-map (kbd "j"	   ) #'vundo-next     )
  (define-key vundo-mode-map (kbd "<down>" ) #'vundo-next     )
  (define-key vundo-mode-map (kbd "k"	   ) #'vundo-previous )
  (define-key vundo-mode-map (kbd "<up>"   ) #'vundo-previous )
  (define-key vundo-mode-map (kbd "<home>" ) #'vundo-stem-root)
  (define-key vundo-mode-map (kbd "<end>"  ) #'vundo-stem-end )
  (define-key vundo-mode-map (kbd "q"	   ) #'vundo-quit     )
  (define-key vundo-mode-map (kbd "C-g"    ) #'vundo-quit     )
  (define-key vundo-mode-map (kbd "RET"    ) #'vundo-confirm  )

  (evil-global-set-key 'normal (kbd "C-x u") #'vundo)
  (global-set-key (kbd "C-x u") #'vundo)
  )

;; Save list of recent files
(recentf-mode 1)
(global-set-key (kbd "C-c r") #'consult-recent-file)

(use-package emacs
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)

  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
  (setq read-extended-command-predicate
        #'command-completion-default-include-p)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete))

;; Enable vertico
(use-package vertico
  :bind (:map vertico-map
	      ("C-k" . vertico-previous)
	      ("C-j" . vertico-next    ))

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
(savehist-mode 1)

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
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)

	 ("C-x y" . consult-yank-from-kill-ring)
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

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
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

(global-set-key (kbd "C-x RET RET") 'consult-theme)


(use-package embark
  :ensure t

  :bind
  (("C-;" . embark-act)         ;; pick some comfortable binding
   ("M-'" . embark-act)
   ("C-." . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)  ;; alternative for `describe-bindings'

   :map evil-normal-state-map
   ("C-;" . embark-act)
   ("C-." . embark-dwim)
   )

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc.  You may adjust the Eldoc
  ;; strategy, if you want to see the documentation from multiple providers.
  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\|Collect\\|Act\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))


;; (defun make-silent (func &rest args)
;;   (cl-letf (((symbol-function 'message)
;; 	     (lambda (&rest args) nil)))
;;     (apply func args)))

;; (advice-add 'god-mode :around #'make-silent)


;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;;; panimacs-lsp.el --- panimacs :: completions and fuzzy matching -*- lexical-binding: t -*-

(setq-default truncate-lines t)

(use-package projectile
  :bind
  ("C-x p f" . projectile-find-file)
  ("C-x p r" . projectile-ripgrep)
  ("C-x p d" . projectile-find-dir)
  ("C-x p v" . projectile-run-vterm)
  ("C-x p c" . projectile-compile-project)
  ("C-x p o" . projectile-find-other-file)
  )

(use-package ripgrep)


(use-package orderless
  :demand t
  :config
  (setq completion-styles '(orderless partial-completion)
        completion-category-defaults nil
        completion-category-overrides '((file (styles . (partial-completion))))))

(use-package yasnippet
  :diminish yas-minor-mode
  :hook (prog-mode . yas-minor-mode)
  :config (yas-reload-all))

(use-package yasnippet-snippets
  :defer t
  :after yasnippet)

(add-to-list 'auto-mode-alist
             '("\\.ts\\'" . typescript-ts-mode))

(use-package docker
  :ensure t
  :bind ("C-c d" . docker))

(use-package dockerfile-mode)

(defun panimacs/c-mode-common-hook ()
  ;; my customizations for all of c-mode, c++-mode, objc-mode, java-mode
  (c-set-offset 'substatement-open 0)
  ;; other customizations can go here

  (setq c++-tab-always-indent t)
  (setq c-basic-offset 4)
  (setq c-ts-common-indent-offset 4)
  (setq c-indent-level 4)

  (setq tab-stop-list '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60))
  (setq tab-width 4)
  (setq indent-tabs-mode nil))

(add-hook 'c-mode-common-hook 'panimacs/c-mode-common-hook)


(use-package cmake-mode)


(use-package nix-mode
  :mode "\\.nix\\'")

(defun my-indent-style()
  "Override the built-in BSD indentation style with some additional rules"
  `(;; Here are your custom rules
    ((node-is ")") parent-bol 0)
    ((match nil "argument_list" nil 1 1) parent-bol c-ts-mode-indent-offset)
    ((parent-is "argument_list") prev-sibling 0)
    ((match nil "parameter_list" nil 1 1) parent-bol c-ts-mode-indent-offset)
    ((parent-is "parameter_list") prev-sibling 0)

    ;; Append here the indent style you want as base
    ,@(alist-get 'bsd (c-ts-mode--indent-styles 'cpp))))

(setq c-ts-mode-indent-offset 4)
(setq c-ts-mode-indent-style 'gnu)
(add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode))
(add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))
(add-to-list 'major-mode-remap-alist '(c-or-c++-mode . c-or-c++-ts-mode))


(use-package aggressive-indent)
(global-aggressive-indent-mode)


(use-package haskell-mode)


;; Configure compilation buffer colors
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)


(use-package treesit-auto
  :demand t
  :config
  (global-treesit-auto-mode))


(use-package eat)

(use-package hide-mode-line)

(use-package sudo-edit
  :ensure t
  :after embark
  :bind
  (:map embark-file-map
        ("s" . sudo-edit-find-file))
  (:map embark-become-file+buffer-map
        ("s" . sudo-edit-find-file)))

(use-package vterm
  :ensure t
  ;; :hook (vterm-mode . hide-mode-line-mode) ; modeline serves no purpose in vterm
  :hook (vterm-mode . turn-off-evil-mode)
  :init
  ;; Once vterm is dead, the vterm buffer is useless. Why keep it around? We can
  ;; spawn another if want one.
  (setq vterm-timer-delay 0.01)

  (evil-set-initial-state 'vterm-mode 'emacs)
  (with-eval-after-load 'tramp
    (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

  (setq vterm-kill-buffer-on-exit t)
  (setq vterm-tramp-shells '(("ssh" "/usr/bin/zsh") ("scp" "/usr/bin/zsh") ("su" "/usr/bin/zsh") ("docker" "/bin/sh")))

  ;; 50000 lines of scrollback, instead of 1000
  (setq vterm-max-scrollback 50000))

(defun run-in-vterm-kill (process event)
  "A process sentinel. Kills PROCESS's buffer if it is live."
  (let ((b (process-buffer process)))
    (and (buffer-live-p b)
         (kill-buffer b))))

(defun run-in-vterm (command)
  "Execute string COMMAND in a new vterm.

Interactively, prompt for COMMAND with the current buffer's file
name supplied. When called from Dired, supply the name of the
file at point.

Like `async-shell-command`, but run in a vterm for full terminal features.

The new vterm buffer is named in the form `*foo bar.baz*`, the
command and its arguments in earmuffs.

When the command terminates, the shell remains open, but when the
shell exits, the buffer is killed."
  (interactive
   (list
    (let* ((f (cond (buffer-file-name)
                    ((eq major-mode 'dired-mode)
                     (dired-get-filename nil t))))
           (filename (concat " " (shell-quote-argument (and f (file-relative-name f))))))
      (read-shell-command "Terminal command: "
                          (cons filename 0)
                          (cons 'shell-command-history 1)
                          (list filename)))))
  (with-current-buffer (vterm (concat "*" command "*"))
    (set-process-sentinel vterm--process #'run-in-vterm-kill)
    (vterm-send-string command)
    (vterm-send-return)))

(global-set-key (kbd "C-x M-RET") #'run-in-vterm)


(use-package multi-vterm
	:config
	(setq vterm-keymap-exceptions nil)
	(global-set-key            (kbd "C-x v v")    #'multi-vterm)
        (global-set-key            (kbd "C-x p RET")  #'multi-vterm-project)
        (global-set-key            (kbd "C-'")        #'multi-vterm-dedicated-toggle)
	(define-key vterm-mode-map (kbd "C-x v v")    #'multi-vterm)
	(define-key vterm-mode-map (kbd "M-TAB")      #'multi-vterm-next)
	(define-key vterm-mode-map (kbd "M-S-TAB")    #'multi-vterm-prev))

(setq tramp-shell-prompt-pattern "\\(?:^\\|\r\\)[^]#$%>\n]*#?[]#$%>].* *\\(^[\\[[0-9;]*[a-zA-Z] *\\)*")


;; TODO: make it so it works in tramp
(cl-loop for file in '("/bin/zsh" "/usr/bin/zsh" "/usr/local/bin/bash" "/bin/bash")
        when (file-exists-p file)
        do (progn
            (setq shell-file-name file)
            (cl-return)))

(setenv "SHELL" shell-file-name)
(setq vterm-shell shell-file-name)
(setq-default vterm-shell shell-file-name)


(use-package magit
  :config
  (setq magit-auto-revert-mode t)
  (setq magit-refresh-status-buffer 'magit-refresh-status-buffer-quietly))

(use-package diff-hl
  :config
  (global-diff-hl-mode 1)
  (diff-hl-margin-mode 1)

  (setq diff-hl-draw-borders nil)
  :hook (prog-mode . diff-hl-flydiff-mode))



;; (use-package python-mode
;;   :init
;;   (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode)))

;; Make eglot correctly detect project root in some cases:

;; All taken from https://andreyor.st/posts/2022-07-16-project-el-enhancements/

(defcustom project-root-markers
  '("Cargo.toml" "compile_commands.json" "compile_flags.txt"
    "project.clj" ".git" "deps.edn" "shadow-cljs.edn" ".projectile" ".envrc" "build")
  "Files or directories that indicate the root of a project."
  :type '(repeat string)
  :group 'project)

(defun project-root-p (path)
  "Check if the current PATH has any of the project root markers."
  (catch 'found
    (dolist (marker project-root-markers)
	  (when (file-exists-p (concat path marker))
        (throw 'found marker)))))

(defun project-find-root (path)
  "Search up the PATH for `project-root-markers'."
  (let ((path (expand-file-name path)))
    (catch 'found
	  (while (not (equal "/" path))
	    (if (not (project-root-p path))
	        (setq path (file-name-directory (directory-file-name path)))
	      (throw 'found (cons 'transient path)))))))

(add-to-list 'project-find-functions #'project-find-root)

(defun project-save-some-buffers (&optional arg)
  "Save some modified file-visiting buffers in the current project.

Optional argument ARG (interactively, prefix argument) non-nil
means save all with no questions."
  (interactive "P")
  (let* ((project-buffers (project-buffers (project-current)))
         (pred (lambda () (memq (current-buffer) project-buffers))))
    (funcall-interactively #'save-some-buffers arg pred)))

(define-advice project-compile (:around (fn) save-project-buffers)
  "Only ask to save project-related buffers."
  (let* ((project-buffers (project-buffers (project-current)))
         (compilation-save-buffers-predicate
          (lambda () (memq (current-buffer) project-buffers))))
    (funcall fn)))

(define-advice recompile (:around (fn &optional edit-command) save-project-buffers)
  "Only ask to save project-related buffers if inside a project."
  (if (project-current)
	  (let* ((project-buffers (project-buffers (project-current)))
             (compilation-save-buffers-predicate
		      (lambda () (memq (current-buffer) project-buffers))))
        (funcall fn edit-command))
    (funcall fn edit-command)))


;; (use-package lsp-mode
;;   :custom
;;   ((lsp-keymap-prefix "C-c l")
;;    (lsp-headerline-breadcrumb-enable nil)
;;    ;; OPTIMIZATION
;;    (read-process-output-max (* 1024 1024)))
;;   :hook ((c-ts-mode . lsp-deferred) (c++-ts-mode . lsp-deferred))
;;   :config
;;   (lsp-enable-which-key-integration t)
;;   :commands (lsp lsp-deferred))

;; (use-package lsp-ui
;;   :custom
;;   (flycheck-indication-mode 'right-fringe)
;;   :custom
;;   ((lsp-ui-sideline-show-diagnostics t)
;;    (lsp-ui-sideline-show-code-actions t)
;;    (lsp-ui-doc-show-with-cursor nil)
;;    (lsp-ui-doc-show-with-cursor nil)
;;    (lsp-ui-doc-show-with-mouse  nil)
;;    ))

(use-package envrc
  :after (flymake eglot)
  :init (envrc-global-mode))

(org-babel-do-load-languages
 'org-babel-load-languages '((python . t)))

(setq-default indent-tabs-mode nil)
(setq-default electric-indent-inhibit t)


(setq python-indent-offset 4)

(org-babel-do-load-languages
 'org-babel-load-languages '((C . t)))



(defun panimacs/compile-project-advice-no-project (old-function)
  "Advice for project-compile that invokes compile
when there's no active project."

  (condition-case nil (funcall old-function)
    (error (call-interactively #'compile)))
  )

(advice-add 'project-compile :around #'panimacs/compile-project-advice-no-project)

(use-package popper
  :ensure t
  :bind (("M-j"   . popper-cycle)
         ("M-k"   . popper-toggle)
         ("M-S-j" . popper-toggle-type)
         ("M-S-k" . popper-kill-latest-popup))
  :config
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "\\*Async Shell Command\\*"
          help-mode
          helpful-mode
          compilation-mode))
  (popper-mode +1)
  (popper-echo-mode +1)
  (setq popper-group-function #'popper-group-by-project)
  (setq popper-display-function #'display-buffer-in-side-window)
  (setq popper-mode-line '(:eval (propertize " POP " 'face 'mode-line-emphasis)))
  (setq popper-display-control nil)
  )

;; Setup display-buffer-alist for different windows
(add-to-list 'display-buffer-alist
            '("\\*e?shell\\*"
                (display-buffer-in-side-window)
                (side . bottom)
                (slot . -1) ;; -1 == L  0 == Mid 1 == R
                (window-height . 0.33) ;; take 2/3 on bottom left
                (window-parameters
                (no-delete-other-windows . nil))))

(add-to-list 'display-buffer-alist
            '("\\*\\(Backtrace\\|Compile-log\\|Messages\\|Warnings\\)\\*"
                (display-buffer-in-side-window)
                (side . bottom)
                (slot . 0)
                (window-height . 0.33)
                (window-parameters
                (no-delete-other-windows . nil))))

(add-to-list 'display-buffer-alist
            '("\\*\\([Hh]elp\\|Command History\\|command-log\\)\\*"
                (display-buffer-in-side-window)
                (side . right)
                (slot . 0)
                (window-width . 80)
                (window-parameters
                (no-delete-other-windows . nil))))

(add-to-list 'display-buffer-alist
            '("\\*TeX errors\\*"
                (display-buffer-in-side-window)
                (side . bottom)
                (slot . 3)
                (window-height . shrink-window-if-larger-than-buffer)
                (dedicated . t)))

(add-to-list 'display-buffer-alist
            '("\\*TeX Help\\*"
                (display-buffer-in-side-window)
                (side . bottom)
                (slot . 4)
                (window-height . shrink-window-if-larger-than-buffer)
                (dedicated . t)))


(use-package ace-window
  :init (ace-window-display-mode 1)
  :config
  (setq aw-dispatch-always t)
  (setq aw-keys '(?0 ?1 ?2 ?3 ?4 ?5 ?6 ?7 ?8 ?9))
  (setq aw-background t)
  (setq aw--lead-overlay-fn 'ignore)

  (defun panimacs/select-window (index)
    ;; TODO: make sure it always matches with number:
    (aw-switch-to-window (nth index (aw-window-list))))

  (defvar-keymap panimacs/ace-winum-keymap
    :doc "Keymap for winum-mode actions."
    "M-0" (lambda () (interactive) (panimacs/select-window 0))
    "M-1" (lambda () (interactive) (panimacs/select-window 1))
    "M-2" (lambda () (interactive) (panimacs/select-window 2))
    "M-3" (lambda () (interactive) (panimacs/select-window 3))
    "M-4" (lambda () (interactive) (panimacs/select-window 4))
    "M-5" (lambda () (interactive) (panimacs/select-window 5))
    "M-6" (lambda () (interactive) (panimacs/select-window 6))
    "M-7" (lambda () (interactive) (panimacs/select-window 7))
    "M-8" (lambda () (interactive) (panimacs/select-window 8))
    "M-9" (lambda () (interactive) (panimacs/select-window 9))
    )

  (define-minor-mode panimacs/ace-winum-mode
    "Switch to windows by pressing M-<number>"
    :global t :keymap panimacs/ace-winum-keymap)

  (panimacs/ace-winum-mode 1)

  (global-set-key (kbd "C-o") #'ace-window)
  (evil-global-set-key 'normal (kbd "C-o") #'ace-window)
  (evil-global-set-key 'motion (kbd "C-o") #'ace-window)
  (define-key vterm-mode-map (kbd "C-o") #'ace-window)


  (defun other-window-mru ()
    "Select the most recently used window on this frame."
    (interactive)
    (when-let ((mru-window
                (get-mru-window
                 nil nil 'not-this-one-dummy)))
      (select-window mru-window)))

  (advice-add 'other-window-mru :before
              (defun other-window-split-if-single (&rest _)
                "Split the frame if there is a single window."
                (when (one-window-p) (split-window-sensibly))))

  (keymap-global-set "M-o" 'other-window-mru)
  (evil-global-set-key 'normal (kbd "M-o") 'other-window-mru)
  (evil-global-set-key 'motion (kbd "M-o") 'other-window-mru)


  (setq other-window-scroll-default #'get-lru-window)


  (defun panimacs/ace-window--wrapped-aw-select (action)
    (if action
        (funcall action (selected-window))))

  (defvar panimacs/ace-window--aw-dispatch-alist-current-window
    (cl-loop for (symbol action description)
             in aw-dispatch-alist
             collect
             (remove
              nil
              (list symbol
                    (if description
                        `(lambda ()
                           (panimacs/ace-window--wrapped-aw-select ',action))
                      action)
                    (if description (concat description " (current window)") nil)))
             )
    )

  (defun panimacs/ace-window-current ()
    (interactive)

    (let ((aw-dispatch-alist panimacs/ace-window--aw-dispatch-alist-current-window)
          (aw-dispatch-function
           (lambda (char)
             (funcall (cadr
                       (assoc char panimacs/ace-window--aw-dispatch-alist-current-window))))))
      (ignore-errors (ace-window 1))
      )
    )

  (keymap-global-set "C-S-o" #'panimacs/ace-window-current)
  (evil-global-set-key 'normal (kbd "C-S-o") #'panimacs/ace-window-current)
  (evil-global-set-key 'motion (kbd "C-S-o") #'panimacs/ace-window-current)
  
  (defun panimacs/ace-set-other-window ()
    "Select a window with ace-window and set it as the \"other
window\" for the current one."
    (interactive)
    (when (> (length (ace-window-list)) 1)
      (when-let* ((win (aw-select " ACE"))
                  (buf (window-buffer buf)))
        (setq-local other-window-scroll-buffer buf))
      )
    )

)


(winner-mode 1)

(global-set-key (kbd "C-x C-j") #'winner-undo)
(global-set-key (kbd "C-x C-k") #'winner-redo)



(with-eval-after-load 'embark
  (defun panimacs/image-display-external (file)
    "Display file at point using an external viewer.
The viewer is specified by the value of `image-dired-external-viewer'."

    ;; TODO: For now it doesn't delete output file when image viewer is closed,
    ;;       probably should make it do so.

    (interactive "fSelect image: ")
    (let* ((local-file (if (not (file-remote-p file)) file
			 (let ((temp-image-file
				(make-temp-file "/tmp/panimacs-remote-image-copy" nil (format ".%s" (file-name-extension file)))))
                           (copy-file file temp-image-file :override-if-exists)
                           temp-image-file)
			 )
                       )
           )

      (start-process "image-dired-external" nil
                     image-dired-external-viewer local-file)))

  (define-key embark-file-map (kbd "V") 'panimacs/image-display-external))

(global-set-key (kbd "C-x M-c M-c") #'save-buffers-kill-emacs)
(global-set-key (kbd "C-x M-c M-k") #'kill-emacs)

(use-package persp-mode
  :init (persp-mode +1)
  :config

  (setq persp-auto-save-opt 0)
  (setq persp-init-new-frame-behaviour-override (lambda (&rest args)))

  (setq initial-major-mode 'org-mode)

  (setq persp-auto-resume-time -1.0)
  )


;; -*- lexical-binding: t -*-


(use-package corfu
  :demand t
  :custom ((corfu-auto        t)
	   (corfu-auto-delay  0)
	   (corfu-auto-prefix 2)
	   (corfu-quit-no-match 'separator)
	   (completion-styles '(orderless basic)))
  :init (global-corfu-mode))

(use-package kind-icon
  :ensure t
  :after corfu
  :custom (
           (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
           (kind-icon-default-style
            '(:padding 0 :stroke 0 :margin 0 :radius 0 :height 0.5 :scale 1)))

  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter)
  )

;;(use-package eglot
;;  :custom
;;  ((read-process-output-max (* 1024 1024)))
;;
;;  :hook ((       c-ts-mode . eglot-ensure)
;;         (     c++-ts-mode . eglot-ensure)
;;         (c-or-c++-ts-mode . eglot-ensure)
;;
;;         (  python-ts-mode . eglot-ensure))
;;  :commands (eglot eglot-ensure)
;;  :config
;;  (set-face-attribute 'eglot-highlight-symbol-face nil :inherit 'lazy-highlight))

(setq flymake-indicator-type 'fringes)

;; ;; Pasted from eglot-booster.el:

;; (require 'eglot)
;; (require 'jsonrpc)

;; (defcustom eglot-booster-no-remote-boost nil
;;   "If non-nil, do not boost remote hosts."
;;   :group 'eglot
;;   :type 'boolean)

;; (defun eglot-booster-plain-command (com)
;;   "Test if command COM is a plain eglot server command."
;;   (and (consp com)
;;        (not (integerp (cadr com)))
;;        (not (memq :autoport com))))

;; (defvar-local eglot-booster-boosted nil)
;; (defun eglot-booster--jsonrpc--json-read (orig-func)
;;   "Read JSON or bytecode, wrapping the ORIG-FUNC JSON reader."
;;   (if eglot-booster-boosted ; local to process-buffer
;;       (or (and (= (following-char) ?#)
;; 	       (let ((bytecode (read (current-buffer))))
;; 		 (when (byte-code-function-p bytecode)
;; 		   (funcall bytecode))))
;; 	  (funcall orig-func))
;;     ;; Not in a boosted process, fallback
;;     (funcall orig-func)))

;; (defun eglot-booster--init (server)
;;   "Register eglot SERVER as boosted if it is."
;;   (when-let ((server)
;; 	     (proc (jsonrpc--process server))
;; 	     (com (process-command proc))
;; 	     (buf (process-buffer proc)))
;;     (unless (and (file-remote-p default-directory) eglot-booster-no-remote-boost)
;;       (if (file-remote-p default-directory) ; com will likely be /bin/sh -i or so
;; 	  (when (seq-find (apply-partially #'string-search "emacs-lsp-booster")
;; 			  (process-get proc 'remote-command)) ; tramp applies this
;; 	    (with-current-buffer buf (setq eglot-booster-boosted t)))
;; 	(when (string-search "emacs-lsp-booster" (car-safe com))
;; 	  (with-current-buffer buf (setq eglot-booster-boosted t)))))))

;; (defvar eglot-booster--boost
;;   '("emacs-lsp-booster" "--json-false-value" ":json-false" "--"))

;; (defun eglot-booster--wrap-contact (args)
;;   "Wrap contact within ARGS if possible."
;;   (let ((contact (nth 3 args)))
;;     (cond
;;      ((and eglot-booster-no-remote-boost (file-remote-p default-directory)))
;;      ((functionp contact)
;;       (setf (nth 3 args)
;; 	    (lambda (&optional interactive)
;; 	      (let ((res (funcall contact interactive)))
;; 		(if (eglot-booster-plain-command res)
;; 		    (append eglot-booster--boost res)
;; 		  res)))))
;;      ((eglot-booster-plain-command contact)
;;       (setf (nth 3 args) (append eglot-booster--boost contact))))
;;     args))

;; ;;;###autoload
;; (define-minor-mode eglot-booster-mode
;;   "Minor mode which boosts plain eglot server programs with emacs-lsp-booster.
;; The emacs-lsp-booster program must be compiled and available on
;; variable `exec-path'.  Only local stdin/out-based lsp servers can
;; be boosted."
;;   :global t
;;   :group 'eglot
;;   (cond
;;    (eglot-booster-mode
;;     (unless (executable-find "emacs-lsp-booster")
;;       (setq eglot-booster-mode nil)
;;       (user-error "The emacs-lsp-booster program is not installed"))
;;     (advice-add 'jsonrpc--json-read :around #'eglot-booster--jsonrpc--json-read)
;;     (advice-add 'eglot--connect :filter-args #'eglot-booster--wrap-contact)
;;     (add-hook 'eglot-server-initialized-hook #'eglot-booster--init))
;;    (t
;;     (advice-remove 'jsonrpc--json-read #'eglot-booster--jsonrpc--json-read)
;;     (advice-remove 'eglot--connect #'eglot-booster--wrap-contact)
;;     (remove-hook 'eglot-server-initialized-hook #'eglot-booster--init))))

;; (eglot-booster-mode)

(use-package lispyville
  :init
  (add-hook 'lisp-mode-hook #'lispyville-mode)
  (add-hook 'emacs-lisp-mode-hook #'lispyville-mode)
  :config
  (lispyville-set-key-theme
   '(operators additional additional-wrap text-objects slurp/barf-lispy))
  )

(defadvice find-file (before make-directory-maybe (filename &optional wildcards) activate)
  "Create parent directory if not exists while visiting file."
  (unless (file-exists-p filename)
    (let ((dir (file-name-directory filename)))
      (unless (file-exists-p dir)
        (make-directory dir t)))))

