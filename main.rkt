#lang typed/racket

(provide struct/props)

(require (for-syntax racket/syntax
                     racket/function
                     syntax/parse
                     syntax/stx
                     type-expander/expander))

(begin-for-syntax
  (define-syntax-rule (when-attr name . rest)
    (if (attribute name) #`rest #'())))

(define-syntax (struct/props stx)
  (with-disappeared-uses
   (syntax-parse stx
     [(_ (~optional (~and polymorphic (T:id ...)))
         name:id
         (~optional parent:id)
         ([field:id :colon type:type] ...)
         (~or
          (~optional (~and transparent #:transparent))
          (~optional (~seq #:property
                           (~literal prop:custom-write)
                           custom-write:expr))
          (~optional (~seq #:property
                           (~literal prop:equal+hash)
                           equal+hash:expr)))
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

      (define/with-syntax PrinterType
        (maybe-∀ #'(→ ins Output-Port (U #t #f 0 1) Any)))
      (define/with-syntax ComparerType-Equal
        (maybe-∀2 #'(→ ins ins2 (→ Any Any Boolean) Any)))
      (define/with-syntax ComparerType-Hash1
        (maybe-∀ #'(→ ins (→ Any Integer) Integer)))
      (define/with-syntax ComparerType-Hash2
        (maybe-∀ #'(→ ins (→ Any Integer) Integer)))
      (define/with-syntax ComparerType
        #'(List ComparerType-Equal
                ComparerType-Hash1
                ComparerType-Hash2))
     
      #`(begin
          #,@(when-attr custom-write
               (: printer PrinterType)
               (: printer-implementation PrinterType)
               (define (printer self port mode)
                 (printer-implementation self port mode)))
         
          #,@(when-attr equal+hash
               (: eq+h ComparerType)
               (: eq+h-implementation (→ ComparerType))
               (define eq+h
                 (list (ann (λ (a b r) ((car (eq+h-implementation)) a b r))
                            ComparerType-Equal)
                       (ann (λ (a r) ((cadr (eq+h-implementation)) a r))
                            ComparerType-Hash1)
                       (ann (λ (a r) ((caddr (eq+h-implementation)) a r))
                            ComparerType-Hash2))))
         
          (struct #,@(when-attr polymorphic (T ...))
            name
            #,@(when-attr parent parent)
            ([field : type] ...)
            #,@(when-attr transparent #:transparent)
            #,@(when-attr custom-write #:property prop:custom-write printer)
            #,@(when-attr equal+hash #:property prop:equal+hash eq+h))

          #,@(when-attr custom-write
               (define printer-implementation custom-write))
         
          #,@(when-attr equal+hash
               #,(let ()
                   (define/with-syntax equal+hash-ann
                     (syntax-parse #'equal+hash
                       [((~and list (~literal list)) equal? hash1 hash2)
                        #`(list (ann equal?
                                     #,(maybe-∀2
                                        #'(→ ins ins2 (→ Any Any Boolean) Any)))
                                (ann hash1
                                     #,(maybe-∀
                                        #'(→ ins (→ Any Integer) Integer)))
                                (ann hash2
                                     #,(maybe-∀
                                        #'(→ ins (→ Any Integer) Integer))))]
                       [expr:expr #'expr]))
                   #`(define eq+h-implementation (λ () equal+hash-ann)))))])))

