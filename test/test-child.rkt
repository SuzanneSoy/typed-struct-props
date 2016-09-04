#lang typed/racket

(require typed-struct-props
         typed/rackunit)
(define-syntax (test-not-equal? stx)
  (syntax-case stx ()
    [(_ name v1 v2)
     (syntax/loc stx
       (test-false name (equal? v1 v2)))]))

(struct foo-parent ([f : Number]) #:transparent)

(struct/props (A) foo foo-parent ([g : A]) #:transparent
              #:property prop:equal+hash (list (λ (a b rec) #f)
                                               (λ (a rec) 42)
                                               (λ (a rec) 43)))

(test-not-exn "The structure's constructor and type work properly"
              (λ () (ann (foo 12 "b") (foo String))))

(test-equal? "The structure's constructor and accessor for a field declared by
 the parent work properly"
             (ann (foo-parent-f (foo 12 "b")) Number)
             12)

(test-equal? "The structure's constructor and accessor work properly"
             (ann (foo-g (foo 12 "b")) String)
             "b")

(test-false "The equal? function supplied to #:equal+hash is used"
            (equal? (foo 0 "b") (foo 0 "b")))
  
(test-equal? "The equal-hash-code function supplied to #:equal+hash is used"
             (equal-hash-code (foo 34 "c"))
             (equal-hash-code (foo 56 "d")))

(test-equal?
 "The equal-secondary hash-code function supplied to #:equal+hash is used"
 (equal-secondary-hash-code (foo 78 'e))
 (equal-secondary-hash-code (foo 90 'f)))




(test-not-exn "The parent structure's constructor and type work properly"
              (λ () (ann (foo-parent 12) foo-parent)
                (void)))

(test-equal? "The parent structure's constructor and accessor work properly"
             (ann (foo-parent-f (foo-parent 12)) Number)
             12)

(test-true "The equal? function supplied to #:equal+hash is not used in the
 parent"
           (equal? (foo-parent 0) (foo-parent 0)))
  
(test-not-equal? "The equal-hash-code function supplied to #:equal+hash is not
 used in the parent"
                 (equal-hash-code (foo-parent 34))
                 (equal-hash-code (foo-parent 56)))

(test-not-equal? "The equal-secondary hash-code function supplied to
 #:equal+hash is not used in the parent"
                 (equal-secondary-hash-code (foo-parent 78))
                 (equal-secondary-hash-code (foo-parent 90)))
