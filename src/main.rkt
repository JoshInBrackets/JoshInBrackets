#lang racket

(require scribble/core)
(require scribble/html-properties)

(require markdown)
(require markdown/scrib)

(provide custom-style div script icode cblock
         md file-content ext-image)

;; config is defined in config.rkt
(require "config.rkt")

;; basic elements
(define custom-style (make-style
                      'custom-style
                      (list (head-extra
                             `(link ([rel "shortcut icon"]
                                     [type "image/png"]
                                     [href ,(hash-ref config 'favicon-url)])))
                            (head-extra
                             `(script ([type "text/x-mathjax-config"])
                                      ,(hash-ref config 'mathjax-config))))))

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
