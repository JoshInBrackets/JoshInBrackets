#lang racket

(require scribble/core)
(require scribble/html-properties)

(provide jib-image)

(define (cloudinary-url width path)
  (if width
      ;; https://res.cloudinary.com/kdr2/image/upload/c_scale,w_
      ;; + 600 +/ + img-kdr2-com/main/josh-2022.jpg
      (string-append "https://res.cloudinary.com/kdr2/image/upload/c_scale,w_"
                     (number->string width) "/" path)
      ;; else
      (string-append "https://res.cloudinary.com/kdr2/image/upload/" path)))

(define (jib-image-no-link width path)
  (let ((src (cloudinary-url width path))
        (style "width: auto; height: auto; max-width: 100%;"))
    (make-element
     (make-style #f
                 (list (make-alt-tag "img")
                       (make-attributes `((src . ,src)
                                          (style . ,style)))))
     "")))


(define (jib-image width path)
  (let ((link (cloudinary-url #f path)))
    (make-element
     (make-style #f
                 (list (make-alt-tag "a")
                       (make-attributes `((href . ,link)
                                          (target . "_blank")))))
     (jib-image-no-link width path))))
