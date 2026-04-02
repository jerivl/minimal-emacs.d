(use-package hledger-mode
  ;;; Basic configuration
  (require 'hledger-mode)

  ;; To open files with .journal extension in hledger-mode
  (add-to-list 'auto-mode-alist '("\\.journal\\'" . hledger-mode))
  (add-to-list 'auto-mode-alist '("\\.ledger\\'" . hledger-mode))

  ;; Provide the path to you journal file.
  ;; The default location is too opinionated.
  ; (setq hledger-jfile "/path/to/your/journal-file.journal")

  ;;; Auto-completion for account names
  ;; For company-mode users,
  ; (add-to-list 'company-backends 'hledger-company)

  ;; For auto-complete users,
  (add-to-list 'ac-modes 'hledger-mode)
  (add-hook 'hledger-mode-hook
            (lambda ()
              (setq-local ac-sources '(hledger-ac-source))))

  ;; For easily adjusting dates.
  (define-key hledger-mode-map (kbd "<kp-add>") 'hledger-increment-entry-date)
  (define-key hledger-mode-map (kbd "<kp-subtract>") 'hledger-decrement-entry-date))
