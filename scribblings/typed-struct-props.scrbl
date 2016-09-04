#lang scribble/manual
@require[@for-label[typed-struct-props
                    racket/base]]

@title{Struct type properties for Typed/Racket}
@author[@author+email["Georges Dupéron" "georges.duperon@gmail.com"]]

@defmodule[typed-struct-props]

@defform[#:literals (: prop:custom-write )
         (struct/props maybe-type-vars name ([field : type] ...) options ...)
         #:grammar
         [(maybe-type-vars (code:line)
                           (v ...))
          (options #:transparent
                   (code:line #:property prop:custom-write custom-write)
                   (code:line #:equal+hash equal+hash))]
         #:contracts ([custom-write
                       (∀ (v ...)
                          (→ (name v ...)
                             Output-Port
                             (U #t #f 0 1)
                             Any))]
                      [equal+hash
                       (List (∀ (v ... |v'| ...)
                                (→ (name v ...)
                                   (name |v'| ...)
                                   (→ Any Any Boolean)
                                   Any))
                             (∀ (v ...)
                                (→ (name v ...)
                                   (→ Any Integer)
                                   Integer))
                             (∀ (v ...)
                                (→ (name v ...)
                                   (→ Any Integer)
                                   Integer)))])]{
 This form defines a @racketmodname[typed/racket] struct type, and accepts a
 small subset of @racketmodname[racket]'s struct type properties.

 It implements these struct type properties in a type-safe manner: the current
 implementation in @racketmodname[typed/racket] does not properly type-check
 functions and values used as struct type properties. This library declares the
 user-provided functions outside of the struct definition, with the type given
 above (e.g. 
 @racket[(∀ (v ...) (→ (name v ...) Output-Port (U #t #f 0 1) Any))] for the
 argument of the @racket[prop:custom-write] property), to ensure that these
 functions and values are properly checked.

 The API should (hopefully) stay backward-compatible when Typed/Racket
 officially supports (or rejects) structure type properties. In other words:
 @itemlist[
 @item{If @racketmodname[typed/racket] eventually implements the same interface
   as the one provided by this library, then we will update this library so
   that it simply re-provide @racket[struct] renamed as @racket[struct/props].}
 @item{If @racketmodname[typed/racket] eventually implements some type-safe
   struct type properties, then we will update this library will so that it
   translates back to @racketmodname[typed/racket]'s implementation, as much as
   possible.}
 @item{If @racketmodname[typed/racket] eventually disallows struct type
   properties, then we will update this library so that it uses some 
   @racketmodname[typed/racket/unsafe] tricks to still make them available, if
   it can be done.}]}