[![Build Status,](https://img.shields.io/travis/jsmaniac/typed-struct-props/master.svg)](https://travis-ci.org/jsmaniac/typed-struct-props)
[![Coverage Status,](https://img.shields.io/codecov/c/github/jsmaniac/typed-struct-props/master.svg)](https://codecov.io/gh/jsmaniac/typed-struct-props)
[![Build Stats,](https://img.shields.io/badge/build-stats-blue.svg)](http://jsmaniac.github.io/travis-stats/#jsmaniac/typed-struct-props)
[![Online Documentation.](https://img.shields.io/badge/docs-online-blue.svg)](http://docs.racket-lang.org/typed-struct-props/)

Structure type properties for Typed/Racket
==========================================

This library allows a safer use of some struct type properties with
Typed/Racket.

* Functions and values supplied to `#:property prop:some-prop value-here` are
  typechecked. Their type is computed by this library, and depends on the
  property.

* The API should hopefully remain stable, even if struct type properties
  become supported (this library will then become a wrapper) or forbidden in
  Typed/Racket (this library will then use typed/racket/unsafe tricks).

Currently, the following properties are supported:

* prop:custom-write
* prop:equal+hash