;; Org mode Anki cards
(use-package anki-editor :ensure t)

;; Anki plugin for opening cards in org-mode
((use-package anki-editor-view
   :ensure t
   :config
   (setq anki-editor-view-files (list org-directory))))

;; Import org-mode notes into Anki
;;
;; Start Anki with AnkiConnect installed
;; - Set destination deck name, either as:
;;     (customize-set-variable 'org-anki-default-deck "my-target-deck") in your .emacs
;;     #+ANKI_DECK: my-target-deck on top of an .org file
;;     :ANKI_DECK: my-target-deck in the properties’ drawer of the item
;;     Note that deck mentioned in the above ways must pre-exist (it has to be separately created in the Anki app)
;; - Run org-anki-sync-entry to sync org entry under cursor Note: the card browser must be closed while synchronizing, as it won’t update the note otherwise (issue).
;; - Run org-anki-delete-entry to delete entry under cursor
(use-package org-anki :ensure t)

(use-package gnosis
    :ensure t
    :config
    (gnosis-modeline-mode)
    :bind (("C-c g" . gnosis-dashboard)))
