#lang typed/racket

(require typed-struct-props
         typed/rackunit)

(struct/props (A) foo ([f : A]) #:transparent)

(test-not-exn "The structure's constructor and type work properly"
              (λ () (ann (foo "b") (foo String))))

(test-equal? "The structure's constructor and accessor work properly"
             (ann (foo-f (foo "b")) String)
             "b")

