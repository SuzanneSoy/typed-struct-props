#lang typed/racket

(require typed-struct-props
         typed/rackunit)
(define-syntax (test-not-equal? stx)
  (syntax-case stx ()
    [(_ name v1 v2)
     (syntax/loc stx
       (test-false name (equal? v1 v2)))]))

(struct/props (A) foo-parent ([f : A]) #:transparent
              #:property prop:equal+hash (list (λ (a b rec) #f)
                                               (λ (a rec) 42)
                                               (λ (a rec) 43)))

(struct (A) foo foo-parent ([g : Number]) #:transparent)

(test-not-exn "The structure's constructor and type work properly"
              (λ () (ann (foo "b" 12 ) (foo String))))

(test-equal? "The structure's constructor and accessor for a field declared by
 the parent work properly"
             (ann (foo-parent-f (foo "b" 12)) String)
             "b")

(test-equal? "The structure's constructor and accessor work properly"
             (ann (foo-g (foo "b" 12)) Number)
             12)

(test-false "The equal? function supplied to #:equal+hash is used"
           (equal? (foo "b" 0) (foo "b" 0)))
  
(test-equal? "The equal-hash-code function supplied to #:equal+hash is used"
                 (equal-hash-code (foo "c" 34))
                 (equal-hash-code (foo "d" 56)))

(test-equal? "The equal-secondary hash-code function supplied to #:equal+hash is
 used"
          (equal-secondary-hash-code (foo 'e 78))
          (equal-secondary-hash-code (foo 'f 90)))




(test-not-exn "The parent structure's constructor and type work properly"
              (λ () (ann (foo-parent "b") (foo-parent String))
                (void)))

(test-equal? "The parent structure's constructor and accessor work properly"
             (ann (foo-parent-f (foo-parent "b")) String)
             "b")

(test-false "The equal? function supplied to #:equal+hash is used in the parent"
           (equal? (foo-parent 0) (foo-parent 0)))
  
(test-equal? "The equal-hash-code function supplied to #:equal+hash is used in
 the parent"
                 (equal-hash-code (foo-parent 34))
                 (equal-hash-code (foo-parent 56)))

(test-equal? "The equal-secondary hash-code function supplied to #:equal+hash is
 used in the parent"
                 (equal-secondary-hash-code (foo-parent 78))
                 (equal-secondary-hash-code (foo-parent 90)))
