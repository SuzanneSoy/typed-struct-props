#lang typed/racket

(require typed-struct-props
         typed/rackunit)

(struct/props foo ([f : Number]) #:transparent)

(test-not-exn "The structure's constructor and type work properly"
              (λ () (ann (foo 12) foo)))

(test-equal? "The structure's constructor and accessor work properly"
             (ann (foo-f (foo 12)) Number)
             12)