(use-package terraform-mode
  :ensure t
  :custom (terraform-indent-level 4)
  :config
  (defun my-terraform-mode-init ()
    (outline-minor-mode 1))

  (add-hook 'terraform-mode-hook 'my-terraform-mode-init))
