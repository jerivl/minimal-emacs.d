;; Auto-revert in Emacs is a feature that automatically updates the
;; contents of a buffer to reflect changes made to the underlying file
;; on disk.
(use-package autorevert
  :ensure nil
  :commands (auto-revert-mode global-auto-revert-mode)
  :hook
  (after-init . global-auto-revert-mode)
  :custom
  (auto-revert-interval 3)
  (auto-revert-remote-files nil)
  (auto-revert-use-notify t)
  (auto-revert-avoid-polling nil)
  (auto-revert-verbose t))

;; Recentf is an Emacs package that maintains a list of recently
;; accessed files, making it easier to reopen files you have worked on
;; recently.
(use-package recentf
  :ensure nil
  :commands (recentf-mode recentf-cleanup)
  :hook
  (after-init . recentf-mode)

  :custom
  (recentf-auto-cleanup (if (daemonp) 300 'never))
  (recentf-exclude
   (list "\\.tar$" "\\.tbz2$" "\\.tbz$" "\\.tgz$" "\\.bz2$"
         "\\.bz$" "\\.gz$" "\\.gzip$" "\\.xz$" "\\.zip$"
         "\\.7z$" "\\.rar$"
         "COMMIT_EDITMSG\\'"
         "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
         "-autoloads\\.el$" "autoload\\.el$"))

  :config
  ;; A cleanup depth of -90 ensures that `recentf-cleanup' runs before
  ;; `recentf-save-list', allowing stale entries to be removed before the list
  ;; is saved by `recentf-save-list', which is automatically added to
  ;; `kill-emacs-hook' by `recentf-mode'.
  (add-hook 'kill-emacs-hook #'recentf-cleanup -90))

;; savehist is an Emacs feature that preserves the minibuffer history between
;; sessions. It saves the history of inputs in the minibuffer, such as commands,
;; search strings, and other prompts, to a file. This allows users to retain
;; their minibuffer history across Emacs restarts.
(use-package savehist
  :ensure nil
  :commands (savehist-mode savehist-save)
  :hook
  (after-init . savehist-mode)
  :custom
  (savehist-autosave-interval 600)
  (savehist-additional-variables
   '(kill-ring                        ; clipboard
     register-alist                   ; macros
     mark-ring global-mark-ring       ; marks
     search-ring regexp-search-ring)))

;; save-place-mode enables Emacs to remember the last location within a file
;; upon reopenng. This feature is particularly beneficial for resuming work at
;; the precise point where you previously left off.
(use-package saveplace
  :ensure nil
  :commands (save-place-mode save-place-local-mode)
  :hook
  (after-init . save-place-mode)
  :custom
  (save-place-limit 400))

;; Don't litter file system with *~ backup files; put them all inside
;; ~/.emacs.d/backup or wherever
(defun bedrock--backup-file-name (fpath)
  "Return a new file path of a given file path.
If the new path's directories does not exist, create them."
  (let* ((backupRootDir (concat user-emacs-directory "emacs-backup/"))
         (filePath (replace-regexp-in-string "[A-Za-z]:" "" fpath )) ; remove Windows driver letter in path
         (backupFilePath (replace-regexp-in-string "//" "/" (concat backupRootDir filePath "~") )))
    (make-directory (file-name-directory backupFilePath) (file-name-directory backupFilePath))
    backupFilePath))
(setopt make-backup-file-name-function 'bedrock--backup-file-name)


;; The above creates nested directories in the backup folder. If
;; instead you would like all backup files in a flat structure, albeit
;; with their full paths concatenated into a filename, then you can
;; use the following configuration:
;; (Run `'M-x describe-variable RET backup-directory-alist RET' for more help)
;;
(let ((backup-dir (expand-file-name "emacs-backup/" user-emacs-directory)))
  (setopt backup-directory-alist `(("." . ,backup-dir))))

;; Sends all new entries to the kill ring to the system clipboard
(use-package clipetty
  :ensure t
  :hook (after-init . global-clipetty-mode))

;; MacOS: Allow emacs to use pbcopy for the system clipboard
;; Also add exec-path-from-shell for macos
;(use-package pbcopy
;  :ensure t
;  :config
;  (turn-on-pbcopy))

;; The stripspace Emacs package provides stripspace-local-mode, a minor mode
;; that automatically removes trailing whitespace and blank lines at the end of
;; the buffer when saving.
(use-package stripspace
  :ensure t
  :commands stripspace-local-mode

  ;; Enable for prog-mode-hook, text-mode-hook, conf-mode-hook
  :hook ((prog-mode . stripspace-local-mode)
         (text-mode . stripspace-local-mode)
         (conf-mode . stripspace-local-mode))

  :custom
  ;; The `stripspace-only-if-initially-clean' option:
  ;; - nil to always delete trailing whitespace.
  ;; - Non-nil to only delete whitespace when the buffer is clean initially.
  ;; (The initial cleanliness check is performed when `stripspace-local-mode'
  ;; is enabled.)
  (stripspace-only-if-initially-clean nil)

  ;; Enabling `stripspace-restore-column' preserves the cursor's column position
  ;; even after stripping spaces. This is useful in scenarios where you add
  ;; extra spaces and then save the file. Although the spaces are removed in the
  ;; saved file, the cursor remains in the same position, ensuring a consistent
  ;; editing experience without affecting cursor placement.
  (stripspace-restore-column t))

;; Apheleia is an Emacs package designed to run code formatters (e.g., Shfmt,
;; Black and Prettier) asynchronously without disrupting the cursor position.
(use-package apheleia
  :ensure t
  :commands (apheleia-mode
             apheleia-global-mode)
  :hook ((prog-mode . apheleia-mode)))

;; Set up the Language Server Protocol (LSP) servers using Eglot.
(use-package eglot
  :ensure nil
  :commands (eglot-ensure
             eglot-rename
             eglot-format-buffer))

;; Tree-sitter in Emacs is an incremental parsing system introduced in Emacs 29
;; that provides precise, high-performance syntax highlighting. It supports a
;; broad set of programming languages, including Bash, C, C++, C#, CMake, CSS,
;; Dockerfile, Go, Java, JavaScript, JSON, Python, Rust, TOML, TypeScript, YAML,
;; Elisp, Lua, Markdown, and many others.
(use-package treesit-auto
:ensure t
:custom
(treesit-auto-install 'prompt)
:config
(treesit-auto-add-to-auto-mode-alist 'all)
(global-treesit-auto-mode))

;; YASnippet is a template system designed that enhances text editing by
;; enabling users to define and use snippets. When a user types a short
;; abbreviation, YASnippet automatically expands it into a full template, which
;; can include placeholders, fields, and dynamic content.
(use-package yasnippet
  :ensure t
  :config
  ;; Enable yasnippet globally
  (yas-global-mode 1)
  ;; Suppress verbose messages
 (setq yas-verbosity 0))

(use-package auto-yasnippet :ensure t)

(use-package popup :ensure t)

(use-package corfu-terminal
  :ensure (:host "https://codeberg.org/akib/emacs-corfu-terminal.git")
  :config
  (unless (display-graphic-p)
  (corfu-terminal-mode +1)))

(use-package kind-icon
  :ensure t
  :after corfu
  ;:custom
  ; (kind-icon-blend-background t)
  ; (kind-icon-default-face 'corfu-default) ; only needed with blend-background
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; Corfu enhances in-buffer completion by displaying a compact popup with
;; current candidates, positioned either below or above the point. Candidates
;; can be selected by navigating up or down.
(use-package corfu
  :ensure t
  :commands
  (corfu-mode global-corfu-mode)
 :hook ((prog-mode . corfu-mode)
         (shell-mode . corfu-mode)
         (eshell-mode . corfu-mode))
 :custom
  ;; Hide commands in M-x which do not apply to the current mode.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Disable Ispell completion function. As an alternative try `cape-dict'.
  (text-mode-ispell-word-completion nil)
  (tab-always-indent 'complete)

  ;; Enable Corfu
  :init
  (global-corfu-mode)
  ;; Enable optional extension modes:
  (corfu-history-mode)
  (corfu-indexed-mode)
  (corfu-popupinfo-mode))

;; Cape, or Completion At Point Extensions, extends the capabilities of
;; in-buffer completion. It integrates with Corfu or the default completion UI,
;; by providing additional backends through completion-at-point-functions.
(use-package cape
  :ensure t
  :commands (cape-dabbrev cape-file cape-elisp-block)
  :bind ("C-c p" . cape-prefix-map)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block))

;; A file and project explorer for Emacs that displays a structured tree
;; layout, similar to file browsers in modern IDEs. It functions as a sidebar
;; in the left window, providing a persistent view of files, projects, and
;; other elsure t
(use-package treemacs
  :ensure t
  :commands (treemacs
             treemacs-select-window
             treemacs-delete-other-windows
             treemacs-select-directory
             treemacs-bookmark
             treemacs-find-file
             treemacs-find-tag)
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag))

  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))

  :config
  (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
        treemacs-deferred-git-apply-delay        0.5
        treemacs-directory-name-transformer      #'identity
        treemacs-display-in-side-window          t
        treemacs-eldoc-display                   'simple
        treemacs-file-event-delay                2000
        treemacs-file-extension-regex            treemacs-last-period-regex-value
        treemacs-file-follow-delay               0.2
        treemacs-file-name-transformer           #'identity
        treemacs-follow-after-init               t
        treemacs-expand-after-init               t
        treemacs-find-workspace-method           'find-for-file-or-pick-first
        treemacs-git-command-pipe                ""
        treemacs-goto-tag-strategy               'refetch-index
        treemacs-header-scroll-indicators        '(nil . "^^^^^^")
        treemacs-hide-dot-git-directory          t
        treemacs-indentation                     2
        treemacs-indentation-string              " "
        treemacs-is-never-other-window           nil
        treemacs-max-git-entries                 5000
        treemacs-missing-project-action          'ask
        treemacs-move-files-by-mouse-dragging    t
        treemacs-move-forward-on-expand          nil
        treemacs-no-png-images                   nil
        treemacs-no-delete-other-windows         t
        treemacs-project-follow-cleanup          nil
        treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
        treemacs-position                        'left
        treemacs-read-string-input               'from-child-frame
        treemacs-recenter-distance               0.1
        treemacs-recenter-after-file-follow      nil
        treemacs-recenter-after-tag-follow       nil
        treemacs-recenter-after-project-jump     'always
        treemacs-recenter-after-project-expand   'on-distance
        treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
        treemacs-project-follow-into-home        nil
        treemacs-show-cursor                     nil
        treemacs-show-hidden-files               t
        treemacs-silent-filewatch                nil
        treemacs-silent-refresh                  nil
        treemacs-sorting                         'alphabetic-asc
        treemacs-select-when-already-in-treemacs 'move-back
        treemacs-space-between-root-nodes        t
        treemacs-tag-follow-cleanup              t
        treemacs-tag-follow-delay                1.5
        treemacs-text-scale                      nil
        treemacs-user-mode-line-format           nil
        treemacs-user-header-line-format         nil
        treemacs-wide-toggle-width               70
        treemacs-width                           35
        treemacs-width-increment                 1
        treemacs-width-is-initially-locked       t
        treemacs-workspace-switch-cleanup        nil)

  ;; The default width and height of the icons is 22 pixels. If you are
  ;; using a Hi-DPI display, uncomment this to double the icon size.
  ;; (treemacs-resize-icons 44)

  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)

  ;;(when treemacs-python-executable
  ;;  (treemacs-git-commit-diff-mode t))

  (pcase (cons (not (null (executable-find "git")))
               (not (null treemacs-python-executable)))
    (`(t . t)
     (treemacs-git-mode 'deferred))
    (`(t . _)
     (treemacs-git-mode 'simple)))

  (treemacs-hide-gitignored-files-mode nil))

(use-package buffer-terminator
    :ensure t
    :custom
    ;; Enable/Disable verbose mode to log buffer cleanup events
    (buffer-terminator-verbose nil)

    ;; Set the inactivity timeout (in seconds) after which buffers are considered
    ;; inactive (default is 30 minutes):
    (buffer-terminator-inactivity-timeout (* 30 60)) ; 30 minutes

    ;; Define how frequently the cleanup process should run (default is every 10
    ;; minutes):
    (buffer-terminator-interval (* 10 60)) ; 10 minutes
    :config
    (buffer-terminator-mode 1))

;; Vertico provides a vertical completion interface, making it easier to
;; navigate and select from completion candidates (e.g., when `M-x` is pressed).
(use-package vertico
  ;; (Note: It is recommended to also enable the savehist package.)
  :ensure t
  :config
  (vertico-mode))

;; Vertico leverages Orderless' flexible matching capabilities, allowing users
;; to input multiple patterns separated by spaces, which Orderless then
;; matches in any order against the candidates.
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless flex))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; Marginalia allows Embark to offer you preconfigured actions in more contexts.
;; In addition to that, Marginalia also enhances Vertico by adding rich
;; annotations to the completion candidates displayed in Vertico's interface.
(use-package marginalia
  :ensure t
  :commands (marginalia-mode marginalia-cycle)
  :init (marginalia-mode))

;; Embark integrates with Consult and Vertico to provide context-sensitive
;; actions and quick access to commands based on the current selection, further
;; improving user efficiency and workflow within Emacs. Together, they create a
;; cohesive and powerful environment for managing completions and interactions.
(use-package embark
  ;; Embark is an Emacs package that acts like a context menu, allowing
  ;; users to perform context-sensitive actions on selected items
  ;; directly from the completion interface.
  :ensure t
  :commands (embark-act
             embark-dwim
             embark-export
             embark-collect
             embark-bindings
             embark-prefix-help-command)
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init
  (setq prefix-help-command #'embark-prefix-help-command)

  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Consult offers a suite of commands for efficient searching, previewing, and
;; interacting with buffers, file contents, and more, improving various tasks.
(use-package consult
  :ensure t
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("C-x t b" . consult-buffer-other-tab)
         ("C-x r b" . consult-bookmark)
         ("C-x p b" . consult-project-buffer)
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)
         ("M-r" . consult-history))

  ;; Enable automatic preview at point in the *Completions* buffer.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  :init
  ;; Optionally configure the register formatting. This improves the register
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Aggressive asynchronous that yield instantaneous results. (suitable for
  ;; high-performance systems.) Note: Minad, the author of Consult, does not
  ;; recommend aggressive values.
  ;; Read: https://github.com/minad/consult/discussions/951
  ;;
  ;; However, the author of minimal-emacs.d uses these parameters to achieve
  ;; immediate feedback from Consult.
  ;; (setq consult-async-input-debounce 0.02
  ;;       consult-async-input-throttle 0.05
  ;;       consult-async-refresh-delay 0.02)

  :config
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))
   (setq consult-narrow-key "<"))

(use-package meow
      :ensure t
      :config
            ;; Remap delete binding based on active region
           (defun my-delete-cmd ()
               (interactive)
               ; "Kill region if it's active and nonempty. Else delete."
               (if (use-region-p)
                   (meow-kill))
                 (meow-delete))

          (defun meow-setup ()
            (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
            (meow-motion-define-key
             '("j" . meow-next)
             '("k" . meow-prev)
             '("<escape>" . ignore))
            (meow-leader-define-key
             ;; Use SPC (0-9) for digit arguments.
             '("1" . meow-digit-argument)
             '("2" . meow-digit-argument)
             '("3" . meow-digit-argument)
             '("4" . meow-digit-argument)
             '("5" . meow-digit-argument)
             '("6" . meow-digit-argument)
             '("7" . meow-digit-argument)
             '("8" . meow-digit-argument)
             '("9" . meow-digit-argument)
             '("0" . meow-digit-argument)
             '("/" . meow-keypad-describe-key)
             '("?" . meow-cheatsheet))
            (meow-normal-define-key
             '("0" . meow-expand-0)
             '("9" . meow-expand-9)
             '("8" . meow-expand-8)
             '("7" . meow-expand-7)
             '("6" . meow-expand-6)
             '("5" . meow-expand-5)
             '("4" . meow-expand-4)
             '("3" . meow-expand-3)
             '("2" . meow-expand-2)
             '("1" . meow-expand-1)
             '("-" . negative-argument)
             ;'(";" . meow-reverse)
             '("," . meow-inner-of-thing)
             '("." . meow-bounds-of-thing)
             '("[" . meow-beginning-of-thing)
             '("]" . meow-end-of-thing)
             '("a" . meow-append)
             ;'("A" . meow-open-below)
             '("b" . meow-back-word)
             '("B" . meow-back-symbol)
             '("c" . meow-change)
             ;'("d" . meow-delete)
             '("D" . meow-backward-delete)
             '("e" . meow-next-word)
             '("E" . meow-next-symbol)
             '("f" . meow-find)
             '(";" . meow-cancel-selection)
             ;'("G" . meow-grab)
             '("h" . meow-left)
             '("H" . meow-left-expand)
             '("i" . meow-insert)
             ;'("I" . meow-open-above)
             '("j" . meow-next)
             '("J" . meow-next-expand)
             '("k" . meow-prev)
             '("K" . meow-prev-expand)
             '("l" . meow-right)
             '("L" . meow-right-expand)
             '("m" . meow-join)
             '("n" . meow-search)
             '("p" . meow-yank)
             '("q" . meow-quit)
             ;'("o" . meow-block)
             ;'("O" . meow-to-block)
             '("Q" . meow-goto-line)
             '("r" . meow-replace)
             '("R" . meow-swap-grab)
             ;'("s" . meow-kill)
             '("t" . meow-till)
             ;'("u" . meow-undo)
             ;'("U" . meow-undo-in-selection)
             ;'("v" . meow-visit)
             '("w" . meow-mark-word)
             '("W" . meow-mark-symbol)
             '("x" . meow-line)
             '("X" . meow-goto-line)
             '("y" . meow-save)
             '("Y" . meow-sync-grab)
             '("z" . meow-pop-selection)
             '("<escape>" . ignore)
             '("'" . repeat)
             ;; Custom bindings
             '("u" . undo-fu-only-undo)
             '("U" . undo-fu-only-redo)
             '("s" . meow-visit)
             '("d" . my-delete-cmd)
             '("M-;" . meow-reverse)
             '("g" . meow-grab)
             '("o" . meow-open-below)
             '("O" . meow-open-above)
             '("I" . meow-block)
             '("A" . meow-to-block)
             '("/" . consult-line)
             '("?" . consult-ripgrep)))

            ;; Remap beacon mode bindings
            (add-hook 'meow-beacon-mode-hook #'(lambda ()
              (if meow-beacon-mode
              (progn
                (meow-normal-define-key
                  '("I" . meow-beacon-insert)
                  '("A" . meow-beacon-append)
                  '("R" . meow-beacon-replace)
                  '("C" . meow-beacon-change)))
              (progn
                (meow-normal-define-key
                  '("I" . meow-block)
                  '("A" . meow-to-block)
                  '("R" . meow-replace)
                  '("C" . meow-change))))))
            (meow-setup)
            (meow-global-mode 1))

;; Enable horizontal scrolling
(setopt mouse-wheel-tilt-scroll t)
(setopt mouse-wheel-flip-direction t)

;; For terminal users, make the mouse more useful
(xterm-mouse-mode 1)

(use-package kirigami
  :ensure t
  :config
  (global-set-key (kbd "C-c z o") 'kirigami-open-fold)     ; Open fold at point
  (global-set-key (kbd "C-c z O") 'kirigami-open-fold-rec) ; Open fold recursively
  (global-set-key (kbd "C-c z r") 'kirigami-open-folds)    ; Open all folds
  (global-set-key (kbd "C-c z c") 'kirigami-close-fold)    ; Close fold at point
  (global-set-key (kbd "C-c z m") 'kirigami-close-folds)   ; Close all folds
  (global-set-key (kbd "C-c z TAB") 'kirigami-toggle-fold) ; Toggle fold at point
)

;; The outline-indent Emacs package provides a minor mode that enables code
;; folding based on indentation levels.
;;
;; In addition to code folding, *outline-indent* allows:
;; - Moving indented blocks up and down
;; - Indenting/unindenting to adjust indentation levels
;; - Inserting a new line with the same indentation level as the current line
;; - Move backward/forward to the indentation level of the current line
;; - and other features.
(use-package outline-indent
  :ensure t
  :commands outline-indent-minor-mode

  :custom
  (outline-indent-ellipsis " ▼")

  :init
  ;; The minor mode can also be automatically activated for a certain modes.
  (add-hook 'python-mode-hook #'outline-indent-minor-mode)
  (add-hook 'python-ts-mode-hook #'outline-indent-minor-mode)

  (add-hook 'yaml-mode-hook #'outline-indent-minor-mode)
  (add-hook 'yaml-ts-mode-hook #'outline-indent-minor-mode))

;; The undo-fu package is a lightweight wrapper around Emacs' built-in undo
;; system, providing more convenient undo/redo functionality.
(use-package undo-fu
:ensure t
:commands (undo-fu-only-undo
           undo-fu-only-redo
           undo-fu-only-redo-all
           undo-fu-disable-checkpoint)
:config (global-unset-key (kbd "C-z"))
        (global-unset-key (kbd "C-Z"))
        (global-set-key (kbd "C-z") 'undo-fu-only-undo)
        (global-set-key (kbd "C-Z") 'undo-fu-only-redo))

;; The undo-fu-session package complements undo-fu by enabling the saving
;; and restoration of undo history across Emacs sessions, even after restarting.
(use-package undo-fu-session
    :ensure t
    :commands undo-fu-session-global-mode
    :hook (after-init . undo-fu-session-global-mode))

;; Enables automatic indentation of code while typing
(use-package aggressive-indent
  :ensure t
  :commands aggressive-indent-mode
  :hook
  (emacs-lisp-mode . aggressive-indent-mode))

;; Highlights function and variable definitions in Emacs Lisp mode
(use-package highlight-defined
  :ensure t
  :commands highlight-defined-mode
  :hook
  (emacs-lisp-mode . highlight-defined-mode))

;; Prevent parenthesis imbalance
(use-package paredit
  :ensure t
  :commands paredit-mode
  :hook
  (emacs-lisp-mode . paredit-mode)
  :config
  (define-key paredit-mode-map (kbd "RET") nil))

;; For paredit+Evil mode users: enhances paredit with Evil mode compatibility
;; --------------------------------------------------------------------------
;; (use-package enhanced-evil-paredit
;;   :ensure t
;;   :commands enhanced-evil-paredit-mode
;;   :hook
;;   (paredit-mode . enhanced-evil-paredit-mode))

;; Displays visible indicators for page breaks
(use-package page-break-lines
  :ensure t
  :commands (page-break-lines-mode
             global-page-break-lines-mode)
  :hook
  (emacs-lisp-mode . page-break-lines-mode))

;; Provides functions to find references to functions, macros, variables,
;; special forms, and symbols in Emacs Lisp
(use-package elisp-refs
  :ensure t
  :commands (elisp-refs-function
             elisp-refs-macro
             elisp-refs-variable
             elisp-refs-special
             elisp-refs-symbol))

(use-package vundo :ensure t)

;; Hide tab bar
(setopt tab-bar-show nil)

;; Helpful is an alternative to the built-in Emacs help that provides much more
;; contextual information.
(use-package helpful
  :ensure t
  :commands (helpful-callable
             helpful-variable
             helpful-key
             helpful-command
             helpful-at-point
             helpful-function)
  :bind
  ([remap describe-command] . helpful-command)
  ([remap describe-function] . helpful-callable)
  ([remap describe-key] . helpful-key)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  :custom
  (helpful-max-buffers 7))

;; which-key: shows a popup of available keybindings when typing a long key
;; sequence (e.g. C-x ...)
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;; Run M-x free-keys to display keys that are unbound
(use-package free-keys :ensure t)

;; The markdown-mode package provides a major mode for Emacs for syntax
  ;; highlighting, editing commands, and preview support for Markdown documents.
  ;; It supports core Markdown syntax as well as extensions like GitHub Flavored
  ;; Markdown (GFM).
  (use-package markdown-mode
      :commands (gfm-mode
                 gfm-view-mode
                 markdown-mode
                 markdown-view-mode)
      :mode (("\\.markdown\\'" . markdown-mode)
            ("\\.md\\'" . markdown-mode)
            ("README\\.md\\'" . gfm-mode))
      :bind (:map markdown-mode-map
            ("C-c C-e" . markdown-do)))

;; Automatically generate a table of contents when editing Markdown files
(use-package markdown-toc
    :ensure t
    :commands
    (markdown-toc-generate-toc
    markdown-toc-generate-or-refresh-toc
    markdown-toc-delete-toc
    markdown-toc--toc-already-present-p)
    :custom
    (markdown-toc-header-toc-title "**Table of Contents**"))

(use-package hledger-mode :ensure t)

; Edit csv
(use-package csv-mode :ensure t)

(use-package writegood-mode :ensure t)

(use-package quick-sdcv
  :ensure t
  :custom
  (quick-sdcv-dictionary-prefix-symbol "►")
  (quick-sdcv-ellipsis " ▼"))

(use-package synosaurus
  :ensure t
  :after corfu
  :config
  (setq synosaurus-backend 'synosaurus-backend-wordnet)
  (setq synosaurus-choose-method 'popup))

(use-package jinx
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages)))
  :custom
  (dolist (hook '(text-mode-hook conf-mode-hook))
  (add-hook hook #'jinx-mode))

;; Org mode is a major mode designed for organizing notes, planning, task
;; management, and authoring documents using plain text with a simple and
;; expressive markup syntax. It supports hierarchical outlines, TODO lists,
;; scheduling, deadlines, time tracking, and exporting to multiple formats
;; including HTML, LaTeX, PDF, and Markdown.
(use-package org
    :ensure t
    :commands (org-mode org-version)
    :mode
    ("\\.org\\'" . org-mode)
    :custom
    (org-hide-leading-stars t)
    (org-startup-indented t)
    (org-adapt-indentation nil)
    (org-edit-src-content-indentation 0)
    ;; (org-fontify-done-headline t)
    ;; (org-fontify-todo-headline t)
    ;; (org-fontify-whole-heading-line t)
    ;; (org-fontify-quote-and-verse-blocks t)
    (org-startup-truncated t)
    :bind
    (:map org-mode-map
          ("C-M-;" . org-comment-dwim)   ;; pick some comfortable binding
     ))
; Shows emphasis syntax when hovered, a la Obsidian
(use-package org-appear
    :ensure t
    :custom
    (add-hook 'org-mode-hook 'org-appear-mode))

(use-package org-modern
  :ensure t
  :config
 (setq org-modern-table nil)
 (add-hook 'org-mode-hook #'org-modern-mode))

; Allow transclusion
(use-package org-transclusion :ensure t)

;; Automatically tangle org-babel source blocks on save
(use-package org-auto-tangle
  :ensure t
  :init
  ;; The minor mode can also be automatically activated for a certain modes.
  (add-hook 'org-mode-hook #'org-auto-tangle-mode))

(use-package org-tanglesync
  :ensure t
  :hook ((org-mode . org-tanglesync-mode)
         ;; enable watch-mode globally:
         ((prog-mode text-mode) . org-tanglesync-watch-mode))
  :custom
  (org-tanglesync-watch-files '("conf.org" "myotherconf.org"))
  :bind
  (( "C-c M-i" . org-tanglesync-process-buffer-interactive)
   ( "C-c M-a" . org-tanglesync-process-buffer-automatic)))

(use-package lambda-themes :ensure (:host github :repo "lambda-emacs/lambda-themes")
  :custom
  (lambda-themes-set-italic-comments t)
  (lambda-themes-set-italic-keywords t)
  (lambda-themes-set-variable-pitch t)
  :config
  ;; load preferred theme
  (load-theme 'lambda-dark))
