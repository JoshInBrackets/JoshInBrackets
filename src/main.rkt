#lang racket

(require scribble/base)
(require scribble/core)
(require scribble/html-properties)

(require markdown)
(require markdown/scrib)

(provide custom-style custom-with custom-toc
         colorize div script icode cblock
         TODO linelist linelist-map paralist
         md file-content ext-image
         zh)

;; config is defined in config.rkt
(require "config.rkt")

;; basic elements
(define custom-style
  (make-style
   'custom-style
   (list (head-extra
          `(link ([rel "shortcut icon"]
                  [type "image/png"]
                  [href ,(hash-ref config 'favicon-url)])))
         (head-extra
          `(script ([type "text/x-mathjax-config"])
                   ,(hash-ref config 'mathjax-config))))))

(define (custom-with . styles)
  (make-style
   'custom-ext
   (append styles (style-properties custom-style))))

(define custom-toc (custom-with 'toc))

(define (colorize #:color c . content)
  (elem #:style (style #f (list (color-property c)))
        content))

(define (div id)
  (make-element
   (make-style #f
               (list (make-alt-tag "div")
                     (make-attributes `((id . ,id)))))
   ""))

(define (script link)
  (make-element
   (make-style #f
               (list (make-alt-tag "script")
                     (make-attributes `((src . ,link)))))
   ""))

(define (icode . code)
  (make-element
   (make-style #f
               (list (make-alt-tag "code")
                     (make-attributes '((class . "inline-code")))))
   (apply string-append code)))

(define (cblock . clines)
  (make-element
   (make-style #f
               (list (make-alt-tag "pre")
                     (make-attributes '((class . "code-block")))))
   (apply string-append clines)))

;; TODO support
(define (TODO tag . lines)
  (let* ((env-tag (getenv "TODO"))
         (text (apply string-append lines))
         (todo (string-append "TODO(" tag "): " text)))
    (when (and env-tag (member env-tag `(,tag "all") string=?))
      (displayln todo))
    (colorize #:color "red" todo)))

;; list support
(define (blank-ele? ele)
  (and (string? ele) (string=? "" (string-trim ele))))
(define (non-blank-ele? ele) (not (blank-ele? ele)))
(define (end-with-ascii s)
  (< (char-utf-8-length (string-ref s (- (string-length s) 1))) 2))

(define (append-space s)
  (if (and (string? s) (end-with-ascii s))
      (string-append s " ")
      s))

(define (linelist-map f . lines)
  (let x ((items '())
          (lines (map
                  append-space
                  (dropf (dropf-right lines blank-ele?) blank-ele?))))
    (cond
      [(empty? lines) (apply itemlist
                             (map (lambda (i) (apply item (apply f i))) items))]
      [else (x (append items (list (takef lines non-blank-ele?)))
               (dropf (dropf lines non-blank-ele?) blank-ele?))])))

(define (linelist . lines)
  (apply linelist-map list lines))

(define (paralist . paras)
  (let x ([paras paras]
          [lines '()])
    (cond
      [(empty? paras) (apply linelist lines)]
      [else (x (dropf (dropf paras blank-ele?) non-blank-ele?)
               (let ([b-pre (takef paras blank-ele?)]
                     [nb-pre
                      (takef (dropf paras blank-ele?) non-blank-ele?)])
                 (if (> (length b-pre) 1)
                     (append lines (cdr b-pre) nb-pre)
                     (append lines nb-pre))))])))

;; file and text
(define (file-content path)
  (string-join (file->lines path) "\n"))

;; markdown support
(define (md . lines)
  (let* ((str (apply string-append lines))
         (xpr (parse-markdown str)))
    (xexprs->scribble-pres xpr)))

;; images
(define (cloudinary-url width path)
  (if width
      ;; https://res.cloudinary.com/kdr2/image/upload/c_scale,w_
      ;; + 600 +/ + img-kdr2-com/main/josh-2022.jpg
      (string-append "https://res.cloudinary.com/kdr2/image/upload/c_scale,w_"
                     (number->string width) "/" path)
      ;; else
      (string-append "https://res.cloudinary.com/kdr2/image/upload/" path)))

(define (ext-image-no-link width path)
  (let ((src (cloudinary-url width path))
        (style "width: auto; height: auto; max-width: 100%;"))
    (make-element
     (make-style #f
                 (list (make-alt-tag "img")
                       (make-attributes `((src . ,src)
                                          (style . ,style)))))
     "")))


(define (ext-image width path)
  (let ((link (cloudinary-url #f path)))
    (make-element
     (make-style #f
                 (list (make-alt-tag "a")
                       (make-attributes `((href . ,link)
                                          (target . "_blank")))))
     (ext-image-no-link width path))))

;; eliminate spaces in Chinese Simplified.
(define (remove-nl l)
  (let ((newl '()))
    (for ([i (range (length l))]
          [e l])
      (when (or (non-blank-ele? e)
                (and (< i (- (length l) 1))
                     (blank-ele? (list-ref l (+ i 1)))))
        (set! newl (append newl (list e)))))
    newl))

(define (chinese-char? c)
  (char>=? c #\u2000))

(define (fix-ending line)
  (if (chinese-char? (string-ref line (- (string-length line) 1)))
      line
      (string-append line " ")))

(define (zh . lines)
  (let* ((evens (remove-nl lines))
         (fixed (map fix-ending evens))
         (full (string-join fixed ""))
         (pars (string-split full "\n"))
         (mk-par (lambda (t) (make-paragraph plain t))))
    (map mk-par pars)))
