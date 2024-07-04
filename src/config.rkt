#lang at-exp racket

(provide config)

(define config
  (hash
   'favicon-url "https://res.cloudinary.com/kdr2/image/upload/img-kdr2-com/main/jib-favicon.png"
   'mathjax-config @~a|{
MathJax.Hub.Config({
    jax: ["input/TeX","output/HTML-CSS"],
    displayAlign: "left"
})}|))
