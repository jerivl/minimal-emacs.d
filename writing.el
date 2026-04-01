(use-package writegood-mode :ensure t)

(use-package quick-sdcv
  :ensure t
  :custom
  (quick-sdcv-dictionary-prefix-symbol "►")
  (quick-sdcv-ellipsis " ▼"))

(use-package synosaurus
  :ensure t
  :config
  (setq synosaurus-backend 'synosaurus-backend-wordnet)
  (setq synosaurus-choose-method 'popup))

(use-package jinx
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages))
  :custom
  (dolist (hook '(text-mode-hook conf-mode-hook))
  (add-hook hook #'jinx-mode)))
