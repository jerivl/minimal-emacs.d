(use-package py-vterm-interaction :ensure t :hook (python-mode . py-vterm-interaction-mode))
(use-package pydoc :ensure t)
(use-package ein :ensure t)
(use-package python-pytest :ensure t)
(use-package pet :ensure t
  :config
  (add-hook 'python-base-mode-hook 'pet-mode -10))
