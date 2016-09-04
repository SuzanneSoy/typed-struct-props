#lang typed/racket

(require typed-struct-props
         typed/rackunit)

(struct/props (A) foo ([f : A]) #:transparent
              #:property prop:custom-write
              (λ (this out mode)
                (fprintf out "#<an-instance ~a>" (foo-f this)))
              #:property prop:equal+hash
              (list (λ (a b rec) #f)
                    (λ (a rec) 42)
                    (λ (a rec) 43)))

(struct/props (A) bar ([f : A]) #:transparent
              #:property prop:custom-write
              (λ (this out mode)
                (fprintf out "#<bar-instance ~a>" (bar-f this))))

(test-not-exn "The structure's constructor and type work properly"
              (λ () (ann (foo "b") (foo String))))

(test-equal? "The structure's constructor and accessor work properly"
             (ann (foo-f (foo "b")) String)
             "b")

(test-equal? "The prop:custom-write is taken into account"
             (format "~a" (foo 1))
             "#<an-instance 1>")

(test-begin
 (test-false "The equal? function supplied to #:equal+hash is used"
             (equal? (foo 0) (foo 0)))

 (test-true "When unspecified, the default implementation of equal? is used"
             (equal? (bar 0) (bar 0))))

(test-equal? "The equal-hash-code function supplied to #:equal+hash is used"
             (equal-hash-code (foo "d"))
             (equal-hash-code (foo "e")))

(test-equal?
 "The equal-secondary hash-code function supplied to #:equal+hash is used"
 (equal-secondary-hash-code (foo 'f))
 (equal-secondary-hash-code (foo 'g)))