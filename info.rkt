#lang info
(define collection "typed-struct-props")
(define deps '("base"
               "rackunit-lib"
               "typed-racket-lib"
               "typed-racket-more"
               "type-expander"))
(define build-deps '("scribble-lib"
                     "racket-doc"
                     "typed-racket-doc"))
(define scribblings
  '(("scribblings/typed-struct-props.scrbl" () ("typed-racket"))))
(define pkg-desc
  (string-append "Makes a small subset of struct type properties available"
                 " in Typed/Racket. The API should hopefully stay"
                 " backward-compatible when Typed/Racket officially supports"
                 " (or rejects) structure type properties."))
(define version "1.0")
(define pkg-authors '(|Suzanne Soy|))
