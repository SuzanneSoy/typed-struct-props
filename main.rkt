#lang typed/racket

(provide struct/props)

(require (for-syntax racket/syntax
                     racket/function
                     syntax/parse
                     syntax/stx))

(begin-for-syntax
  (define-syntax-rule (when-attr name . rest)
    (if (attribute name) #`rest #'())))

(define-syntax struct/props
  (syntax-parser
    [(_ (~optional (~and polymorphic (T:id ...)))
        name:id
        (~optional parent:id)
        (~and fields ([field:id (~literal :) type] ...))
        (~or
         (~optional (~and transparent #:transparent))
         (~optional (~seq #:property (~literal prop:custom-write) custom-write:expr))
         (~optional (~seq #:property (~literal prop:equal+hash) equal+hash:expr)))
        ...)
     (define poly? (and (attribute polymorphic) (not (stx-null? #'(T ...)))))

     (define maybe-∀
       (if poly?
           (λ (result-stx) #`(∀ (T ...) #,result-stx))
           (λ (result-stx) result-stx)))
     
     (define/with-syntax (T2 ...)
       (if poly?
           (stx-map (λ (t) (format-id #'here "~a-2" t)) #'(T ...))
           #'(_unused)))
     (define maybe-∀2
       (if poly?
           (λ (result-stx) #`(∀ (T ... T2 ...) #,result-stx))
           (λ (result-stx) result-stx)))
     
     (define/with-syntax ins
       (if poly? #'(name T ...) #'name))

     (define/with-syntax ins2
       (if poly? #'(name T2 ...) #'name))
     
     #`(begin
         #,@(when-attr custom-write
              (: printer #,(maybe-∀ #'(→ ins Output-Port (U #t #f 0 1) Any)))
              (define printer custom-write))
         #,@(if (attribute equal+hash)
                (let ()
                  (define/with-syntax equal+hash-ann
                    (syntax-parse #'equal+hash
                      [((~and list (~literal list)) equal? hash1 hash2)
                       #`(list (ann equal?
                                    #,(maybe-∀2
                                       #'(→ ins ins2 (→ Any Any Boolean) Any)))
                               (ann hash1
                                    #,(maybe-∀
                                       #'(→ ins (→ Any Fixnum) Fixnum)))
                               (ann hash2
                                    #,(maybe-∀
                                       #'(→ ins (→ Any Fixnum) Fixnum))))]
                      [expr:expr #'expr]))
                  #`((: eq+h (List #,(maybe-∀2
                                      #'(→ ins ins2 (→ Any Any Boolean) Any))
                                   #,(maybe-∀
                                      #'(→ ins (→ Any Fixnum) Fixnum))
                                   #,(maybe-∀
                                      #'(→ ins (→ Any Fixnum) Fixnum))))
                     (define eq+h equal+hash-ann)))
                #'())
     
         (struct #,@(when-attr polymorphic (T ...))
           name
           #,@(when-attr parent parent)
           fields
           #,@(when-attr transparent #:transparent)
           #,@(when-attr custom-write #:property prop:custom-write printer)
           #,@(when-attr equal+hash #:property prop:equal+hash eq+h)))]))

