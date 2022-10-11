#lang racket

;; define Josh as a lambda so that the title can be evaluated.
(define Josh
  (lambda ()
    (let ((actions '("I am doing math!"
                     "I am cubing!"
                     "I am playing Minecraft!")))
      (displayln (list-ref actions (random (length actions)))))))

;; [Josh]
