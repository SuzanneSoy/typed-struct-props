#lang typed/racket

(require typed-struct-props
         typed/rackunit)

(struct/props (A) foo ([f : A]) #:transparent
              #:property prop:custom-write
              (λ (this out mode)
                (fprintf out "#<an-instance ~a>" (foo-f this))))

(test-not-exn "The structure's constructor and type work properly"
              (λ () (ann (foo "b") (foo String))))

(test-equal? "The structure's constructor and accessor work properly"
             (ann (foo-f (foo "b")) String)
             "b")

(test-equal? "The prop:custom-write is taken into account"
             (format "~a" (foo 1))
             "#<an-instance 1>")

