;; menubar always appears, so get rid of it.
(menu-bar-mode -1)
;; if running in graphic mode, then disable tool bar and scroll bars
(if (display-graphic-p)
    (progn
      (tool-bar-mode -1)
      (scroll-bar-mode -1)
      )
)

;; no spam please!
(setq inhibit-splash-screen t)

;; fringe mode config (adjusts the width of the left and right fringe bars)
(fringe-mode 4)


(when (>= emacs-major-version 24)
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
  )

;; Mode line config
(line-number-mode)     ;; show line numbers
(column-number-mode)   ;; and column numbers

;; Cool color themes
(load-theme 'cyberpunk t)
;; (load-theme 'monokai t)

;; Font (requires ttf-inconsolata font installed)
(set-default-font "Inconsolata-10")

;; scroll one line at a time (less "jumpy" than defaults)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse

;; my greatest emacs addiction (auto completion)
(global-set-key "\M- " 'hippie-expand)

;; yeah, why not?
(nyan-mode)

;;(set-face-attribute 'default nil :height 200)

(autoload 'python-mode "python-mode.el" "Python mode." t)
(setq auto-mode-alist (append '(("/.*\.py\'" . python-mode)) auto-mode-alist))


;; backups, don't clutter the dirtree!
(setq
   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.backups"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)       ; use versioned backups

;; open buffers with cursor at last position
(require 'saveplace)
(setq save-place-file (concat user-emacs-directory "saveplace.el"))
(setq-default save-place t)

;; at the minibuffer, please don't allow cursor to go waaay back
(setq minibuffer-prompt-properties 
      (quote (read-only t point-entered minibuffer-avoid-prompt 
			face minibuffer-prompt)))

;; show recent files when opening emacs
(recentf-mode 1)
(recentf-open-files)

;; Open files with external program (xdg-open in this case)
(defun fbc-open-in-external-app ()
  "Open the current file or dired marked files in external app."
  (interactive)
  (let ( doIt
         (myFileList
          (cond
           ((string-equal major-mode "dired-mode") (dired-get-marked-files))
           (t (list (buffer-file-name))) ) ) )
    
    (setq doIt (if (<= (length myFileList) 5)
                   t
                 (y-or-n-p "Open more than 5 files?") ) )
    
    (when doIt
      (cond
       ((string-equal system-type "windows-nt")
        (mapc (lambda (fPath) (w32-shell-execute "open" (replace-regexp-in-string "/" "\\" fPath t t)) ) myFileList)
        )
       ((string-equal system-type "darwin")
        (mapc (lambda (fPath) (shell-command (format "open \"%s\"" fPath)) )  myFileList) )
       ((string-equal system-type "gnu/linux")
        (mapc (lambda (fPath) (let ((process-connection-type nil)) (start-process "" nil "xdg-open" fPath)) ) myFileList) ) ) ) ) )

;; auto wrap lines when editing text
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;; load AucTeX
;;(setq load-path (cons "~/.emacs.d/elpa/auctex-11.87.7" load-path))
;; Currently only working for silver!
;;(load "auctex-pkg.el" nil t t)
;;(load "preview.el" nil t t)       
(setq TeX-auto-save t)
(setq TeX-parse-self t)
;; enable auto '{}' after '_' and -^-
(setq TeX-electric-sub-and-superscript 1)
;; default compiler: pdflatex
(setq TeX-PDF-mode t)
;; enable some goodies such as ` g -> \gamma, ` [ -> \subseteq, etc
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
;; default viewer, adapt depending on platform
(setq TeX-view-program-list
      '(("zathura" "zathura %o") )
      )
(setq TeX-view-program-selection '((output-pdf "zathura")))

;; custom command so that if '{' is inserted in math mode, then we get \{\}
(add-hook 'TeX-mode-hook
 	  (lambda ()
	    (defun mine-insert-set ()
	      "Insert the {} and place cursor in the middle"
	      (interactive)
	      ;;It autocompletes if and only if we are in math mode
	      ;; and the previous character is a \\
	      (if (and  (char-equal 92 (char-before)) (texmathp))
		  (progn 
		    (insert "{\\}")
		   (backward-char 2))
		(insert "{")
		)
	      )
 	    (local-set-key (kbd "{") 'mine-insert-set)
 	    )
 	  )


;; sage mode
;; After installation of the spkg, you must add something like the
;; following to your .emacs:
(add-to-list 'load-path "/sage/fidbc/sage/local/share/emacs/site-lisp/sage-mode")
(require 'sage "sage")
(setq sage-command "/sage/fidbc/sage/sage")
;; If you want sage-view to typeset all your output and have plot()
;; commands inline, uncomment the following line and configure sage-view:
(require 'sage-view "sage-view")
;; (add-hook 'sage-startup-after-prompt-hook 'sage-view)
;; You can use commands like
;; (add-hook 'sage-startup-after-prompt-hook 'sage-view-disable-inline-output)
;; (add-hook 'sage-startup-after-prompt-hook 'sage-view-disable-inline-plots)
;; to enable some combination of features.  Using sage-view requires a
;; working LaTeX installation with the preview package.
;; Also consider running (customize-group 'sage) to see more options.


;; magit stuff
(require 'magit)

;; org stuff
(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
;; add a timestamp whenever we mark a TODO item as DONE
(setq org-log-done 'time)
;; Perhaps don't use this anymore, takes too long to go from TODO -> DONE
(setq org-todo-keywords 
      '((type "TODO" "FEEDBACK" "VERIFY" "|" "DONE" "DELEGATED")))
(setq org-tag-alist '(("@work" . ?w) 
		      ("@home" . ?h) 
		      ("laptop" . ?l) 
		      ("@personal" . ?p)))
(setq org-directory "~/Documents/org")
(setq org-mobile-directory "~/Documents/org/mobile")
;; use C-c [ and C-c ] instead
;;(setq org-agenda-files (quote ("~/Documents/org/agenda.org"))) 
(setq org-mobile-inbox-for-pull "~/Documents/org/mobile_inbox.org")


(require 'ox-publish)
(require 'ox-html)
(setq org-publish-project-alist
  '(
        ("org-notes"               ;Used to export .org file
         :base-directory "~/projects/scribe/www/"  ;directory holds .org files 
         :base-extension "org"     ;process .org file only    
         :publishing-directory "~/projects/scribe/public_html/"    ;export destination
         ;:publishing-directory "/ssh:user@server" ;export to server
         :recursive t
         :publishing-function org-html-publish-to-html
         :headline-levels 4               ; Just the default for this project.
         :auto-preamble t
         :auto-sitemap t                  ; Generate sitemap.org automagically...
         :sitemap-filename "sitemap.org"  ; ... call it sitemap.org (it's the default)...
         :sitemap-title "Sitemap"         ; ... with title 'Sitemap'.
         ;:export-creator-info nil    ; Disable the inclusion of "Created by Org" in the postamble.
         ;:export-author-info nil     ; Disable the inclusion of "Author: Your Name" in the postamble.
         :auto-postamble t         ; Disable auto postamble 
         :table-of-contents t        ; Set this to "t" if you want a table of contents, set to "nil" disables TOC.
         :section-numbers t        ; Set this to "t" if you want headings to have numbers.
         ;:html-postamble "    <p class=\"postamble\">Last Updated %d.</p> " ; your personal postamble
         :style-include-default nil  ;Disable the default css style
        )
        ("org-static"                ;Used to publish static files
         :base-directory "~/projects/scribe/www/"
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
         :publishing-directory "~/projects/scribe/public_html/"
         :recursive t
         :publishing-function org-publish-attachment
         )
        ("org" :components ("org-notes" "org-static")) ;combine "org-static" and "org-static" into one function call
))

;; markdown mode stuff
(autoload 'markdown-mode "markdown-mode" "Markdown mode" t)
(setq auto-mode-alist (cons '("\.md" . markdown-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\.markdown" . markdown-mode) auto-mode-alist))

;; Include the latex-exporter
(require 'ox-latex)
;; Add minted to the defaults packages to include when exporting.
(add-to-list 'org-latex-packages-alist '("" "minted"))
;; Tell the latex export to use the minted package for source
;; code coloration.
(setq org-latex-listings 'minted)
;; Let the exporter use the -shell-escape option to let latex
;; execute external programs.
;; This obviously and can be dangerous to activate!
(setq org-latex-pdf-process
      '("xelatex -shell-escape -interaction nonstopmode -output-directory %o %f"))


;;(add-hook 'tex-mode-hook '(lambda () (longlines-mode 1)))

(setq sml/theme 'dark)
(sml/setup)
(add-to-list 'sml/replacer-regexp-list '("^~/projects/thesis/" ":Thesis:"))

;; http://ergoemacs.org/emacs/elisp_read_file_content.html
(defun get-string-from-file (filePath)
  "Return filePath's file content."
  (with-temp-buffer
    (insert-file-contents filePath)
    (buffer-string)))
(setq display-time-string-forms
       '((propertize (concat " " (substring year -2) "/" month "/" day 
			     "-" 24-hours ":" minutes ":" seconds " " (get-string-from-file "~/.modeline-data") ))))
(display-time)

(display-battery-mode) ;; and battery %
(size-indication-mode) ;; and also the filesize
;(setq display-time-day-and-date t
;      display-time-24hr-format t)

;; ;; AMPL stuff
;; ;; Tell emacs to look in our emacs directory for extensions
;; (setq load-path (cons "~/.emacs.d/opt" load-path))

;; ;;
;; ;; Ampl mode (GNU Math Prog too)
;; ;;

;; (setq auto-mode-alist
;;       (cons '("\\.mod$" . ampl-mode) auto-mode-alist))
;; (setq auto-mode-alist
;;       (cons '("\\.dat$" . ampl-mode) auto-mode-alist))
;; (setq auto-mode-alist
;;       (cons '("\\.ampl$" . ampl-mode) auto-mode-alist))
;; (setq interpreter-mode-alist
;;       (cons '("ampl" . ampl-mode)
;;             interpreter-mode-alist))

;; (load "ampl-mode")

;; ;; Enable syntax coloring
;; (add-hook 'ampl-mode-hook 'turn-on-font-lock)

;; ;; If you find parenthesis matching a nuisance, turn it off by
;; ;; removing the leading semi-colons on the following lines:

;; (setq ampl-auto-close-parenthesis nil)
;; (setq ampl-auto-close-brackets nil)
;; (setq ampl-auto-close-curlies nil)
;; (setq ampl-auto-close-double-quote nil)
;; (setq ampl-auto-close-single-quote nil)
