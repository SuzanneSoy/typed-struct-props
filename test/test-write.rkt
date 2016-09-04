#lang typed/racket

(require typed-struct-props
         typed/rackunit)

(struct/props foo ([f : Number]) #:transparent
              #:property prop:custom-write
              (λ (this out mode)
                (fprintf out "#<f2-instance ~a>" (foo-f this))))

(test-not-exn "The structure's constructor and type work properly"
              (λ () (ann (foo 12) foo)))

(test-equal? "The structure's constructor and accessor work properly"
             (ann (foo-f (foo 12)) Number)
             12)

(test-equal? "The prop:custom-write is taken into account"
             (format "~a" (foo 1))
             "#<f2-instance 1>")