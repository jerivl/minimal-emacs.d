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
