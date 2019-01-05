;;; org-zettelkasten.el --- The org-zettelkasten package -*- lexical-binding: t; -*-

;;; Commentary:
;;; This package ia an implementation of the Zettelkasten method using
;;; the power of Org-mode. It is based on using a single Org file to
;;; house all of the zettels.

;;; Code:

(require 'org)
(require 'org-id)

(defvar ozk-zettelkasten-files '("~/org/zettelkasten.org")
   "The file paths to Zettelkasten files.")

(defvar ozk-zettelkasten-file (car ozk-zettelkasten-files)
  "The file path to the current Zettelkasten file, this defaults to the first element of `ozk-zettelkasten-files'.")

(defvar ozk-header-time-format "%Y%m%d%H%M"
  "Time format string for the Zettel headers.")

(defun ozk-get-header ()
  "Get the header for the current time."
  (format-time-string ozk-header-time-format (current-time)))

(defvar ozk-capture-template
  '("z" "Zettel" entry (file+olp ozk-zettelkasten-file "Zettels")
    "* %(ozk-get-header) %^{Title} %^g\n:properties:\n  :id: %(ozk-get-header)\n:end:\n%?")
  "An org-capture-template for Zettel entries.

To use this template add
`(setq org-capture-templates
       (add-to-list 'org-capture-templates ozk-capture-template))'
to your configuration.")

(defun ozk-set-zettelkasten-file ()
  "Set `ozk-zettelkasten-file' from `ozk-zettelkasten-files'."
  (interactive)
  (setq ozk-zettelkasten-file
        (completing-read "Zettelkasten file: " ozk-zettelkasten-files)))

(defun ozk-create-zettel ()
  "Create a new Zettel."
  (interactive)
  (org-capture nil "z"))

(defun ozk-get-headers ()
  "Return the id headers of the Zettels."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((headers ()))
      (while (re-search-forward "[:space:]*:id: " nil t)
        (message "thing: %s" (thing-at-point 'word t))
        (push (thing-at-point 'word t)
              headers))
      (message "headers: %s" headers)
      headers)))

(defun ozk-id-complete-link ()
  "Create an id link using completion."
  (let ((header-id (completing-read "Header: "
                                    (ozk-get-headers)
                                    nil
                                    'confirm
                                    nil
                                    nil
                                    (format-time-string "%Y" (current-time)))))
    (concat "id:" header-id)))

(defun ozk-search-zettels ()
  "Search for a Zettel with HEADER."
  (interactive)
  (re-search-forward (concat "\\* "
                             (completing-read "Header: "
                                              (ozk-get-headers)
                                              nil
                                              nil
                                              nil
                                              nil
                                              (format-time-string "%Y" (current-time))))))

(org-link-set-parameters "id"
                         :follow #'org-id-open
                         :complete #'ozk-id-complete-link)

(provide 'org-zettelkasten)
;;; org-zettelkasten.el ends here
