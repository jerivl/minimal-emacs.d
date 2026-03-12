;; Compact diagram markup language more lightweight than mermaid.js
(use-package d2-ts-mode :ensure t)
(use-package ob-d2
  :ensure t
  :after (org d2-ts-mode)
  :config
  (setq ob-d2-command d2-ts-mode-d2-executable)
  (add-to-list 'org-babel-load-languages '(d2 . t))
  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages))
