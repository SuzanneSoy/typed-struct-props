#lang typed/racket

(require typed-struct-props
         typed/rackunit)

(struct/props (A) foo1 ([f : A] [g : A]) #:transparent
              #:property prop:custom-write
              (λ (this out mode)
                (write (ann (list (foo1-f this)
                                  (foo1-g this))
                            (Listof A))
                       out)))

(struct/props (A) foo2 ([f : A] [g : A]) #:transparent
              #:property prop:equal+hash
              (list (λ (a b rec)
                      ;; We can access the A ... here, but not the A' ...
                      (ann (list (foo2-f a)
                                 (foo2-g a))
                           (Listof A))
                      #f)
                    (λ (a rec)
                      ;; Type inference works, despite the lambda being in a
                      ;; list, because we detect the special case where a list
                      ;; is immediately constructed.
                      (ann (list (foo2-f a)
                                 (foo2-g a))
                           (Listof A))
                      42)
                    (λ (a rec)
                      ;; Type inference works, despite the lambda being in a
                      ;; list, because we detect the special case where a list
                      ;; is immediately constructed.
                      (ann (list (foo2-f a)
                                 (foo2-g a))
                           (Listof A))
                      43)))

(struct/props (A) foo3 ([f : A] [g : A]) #:transparent
              #:property prop:custom-write
              (λ #:∀ (X) ([this : (foo3 X)] out mode)
                (write (ann (list (foo3-f this)
                                  (foo3-g this))
                            (Listof X))
                       out)))

(struct/props (A) foo4 ([f : A] [g : A]) #:transparent
              #:property prop:equal+hash
              (list (λ #:∀ (Y YY) ([a : (foo4 Y)] [b : (foo4 YY)] rec)
                      ;; We can access the A ... here, but not the A' ...
                      (ann (list (foo4-f a)
                                 (foo4-g a))
                           (Listof Y))
                      (ann (list (foo4-f b)
                                 (foo4-g b))
                           (Listof YY))
                      #f)
                    (λ #:∀ (Z) ([a : (foo4 Z)] rec)
                      ;; Type inference works, despite the lambda being in a
                      ;; list, because we detect the special case where a list
                      ;; is immediately constructed.
                      (ann (list (foo4-f a)
                                 (foo4-g a))
                           (Listof Z))
                      42)
                    (λ #:∀ (W) ([a : (foo4 W)] rec)
                      ;; Type inference works, despite the lambda being in a
                      ;; list, because we detect the special case where a list
                      ;; is immediately constructed.
                      (ann (list (foo4-f a)
                                 (foo4-g a))
                           (Listof W))
                      43)))

;; TODO: write some negative tests.