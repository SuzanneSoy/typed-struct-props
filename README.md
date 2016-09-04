typed-struct-props
=========================

This library allows a safer use of some struct type properties with
Typed/Racket.

* Functions and values supplied to `#:property prop:some-prop value-here` are
  typechecked. Their type is computed by this library, and depends on the
  property.

* The API should hopefully remain stable, even if struct type properties
  become supported (this library will then become a wrapper) or forbidden in
  Typed/Racket (this library will then use typed/racket/unsafe tricks).