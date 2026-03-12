(use-package nix-ts-mode
 :ensure t
 :mode "\\.nix\\'"
 :config
 (setq treesit-font-lock-level 4))

;; Bind nix-update-fetch to a key (C-. u), and then you can very easily
;; update the rev/sha of a fetchgit declaration. Also works for several other fetchers.
(use-package nix-update :ensure t)

;; transparent agenix secrets editing. Open your agenix secret as any
;; other file, make changes and save, it’ll be automatically encrypted back
(use-package agenix :ensure t)
