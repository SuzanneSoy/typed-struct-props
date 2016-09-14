#lang typed/racket

(require typed-struct-props
         typed/rackunit)

(define globl1 : (U #f foo1) #f)

(struct/props foo1 ([f : Number] [g : String]) #:transparent
              #:property prop:custom-write
              (λ (this out mode)
                (set! globl1 (struct-copy foo1 this [g "bbb"]))
                (write "dummy" out)))

(check-equal? (let ([f (foo1 0 "ggg")])
                (check-false globl1)
                (format "~a" f)
                (check-not-false globl1)
                (let ([gl globl1])
                  (if gl
                      (foo1-g gl)
                      'wrong)))
              "bbb")

(define globl2q1 : (U #f foo2) #f)
(define globl2q2 : (U #f foo2) #f)
(define globl2h1 : (U #f foo2) #f)
(define globl2h2 : (U #f foo2) #f)

(struct/props foo2 ([f : Number] [g : String]) #:transparent
              #:property prop:equal+hash
              (list (λ (a b recur)
                      (when (foo2? a)
                        (set! globl2q1 (struct-copy foo2 a [g "bbb-q1"])))
                      (when (foo2? b)
                        (set! globl2q2 (struct-copy foo2 b [g "bbb-q2"])))
                      #f)
                    (λ (a recur)
                      (set! globl2h1 (struct-copy foo2 a [g "bbb-h1"]))
                      0)
                    (λ (a recur)
                      (set! globl2h2 (struct-copy foo2 a [g "bbb-h2"]))
                      0)))

(check-equal? (let ([f1 (foo2 0 "ggg")]
                    [f2 (foo2 1 "hhh")])
                (check-false globl2q1)
                (check-false globl2q2)
                (check-false globl2h1)
                (check-false globl2h2)
                (equal? f1 f2)
                (check-not-false globl2q1)
                (check-not-false globl2q2)
                (check-false globl2h1)
                (check-false globl2h2)
                (let ([gl1 globl2q1]
                      [gl2 globl2q2])
                  (cons (if gl1 (cons (foo2-f gl1) (foo2-g gl1)) 'wrong)
                        (if gl2 (cons (foo2-f gl2) (foo2-g gl2)) 'wrong))))
              '((0 . "bbb-q1")
                .
                (1 . "bbb-q2")))

(set! globl2q1 #f)
(set! globl2q2 #f)

(check-equal? (let ([f (foo2 0 "ggg")])
                (check-false globl2q1)
                (check-false globl2q2)
                (check-false globl2h1)
                (check-false globl2h2)
                (equal-hash-code f)
                (check-false globl2q1)
                (check-false globl2q2)
                (check-not-false globl2h1)
                (check-false globl2h2)
                (let ([gl globl2h1])
                  (if gl (foo2-g gl) 'wrong)))
              "bbb-h1")

(set! globl2h1 #f)

(check-equal? (let ([f (foo2 0 "ggg")])
                (check-false globl2q1)
                (check-false globl2q2)
                (check-false globl2h1)
                (check-false globl2h2)
                (equal-secondary-hash-code f)
                (check-false globl2q1)
                (check-false globl2q2)
                (check-false globl2h1)
                (check-not-false globl2h2)
                (let ([gl globl2h2])
                  (if gl (foo2-g gl) 'wrong)))
              "bbb-h2")
