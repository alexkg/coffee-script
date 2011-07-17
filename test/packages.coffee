test "empty package", ->
  x = {}
  package x.y
    
test "root name is unresolved", ->

  try
    ok nothing is undefined
  catch e
    ok e instanceof ReferenceError
  
  try
    package nothing
      answer: 42
  catch e
    ok e instanceof ReferenceError

  try
    package nothing.something
      answer: 42
  catch e
    ok e instanceof ReferenceError

test "path is created with {} if it doesn't already exist", ->
  base = {}

  package base.x.y.z
    answer: 42
    
  ok base.x.y.z.constructor is Object
  
test "inner names have implicit `this`", ->
  base = {}

  package base
    package inner
      answer: 42

  ok base.inner.constructor is Object
  
  package base
    class Inner
      answer: 42
      
  ok (new base.Inner).answer is 42

test "package names are available to kids", ->
  base = {}
  
  package base
    package one.two.three
    
      package x
        class X

      package y
        class Y extends two.three.x.X # or one.two.three.x.X or three.x.X
      
  ok (new base.one.two.three.y.Y) instanceof base.one.two.three.x.X

test "package names are not available to siblings", ->
  base = {}
  
  package base
    package one.two.three
  
      package x
        class X

      try
        package y
          class Y extends x.X
      catch e
        ok e instanceof ReferenceError

# regarding the last two tests, package names are bound by a closure surrounding the package contents.
# variables are global in coffeescript, so it didn't seem like a good idea to introduce any.

test 'package names can be bound through `this` or with object literal syntax', ->
  base = {}

  package base
    this.x = 1
    @y = 10
    z: 100

  ok base.x is 1
  ok base.y is 10
  ok base.z is 100

test 'packages are evaluated procedurally, even if using object literal syntax', ->
  base = {}

  package base
    X: class
    Y: class extends this.X

  ok new base.Y instanceof base.X

test 'packages can be unnamed', ->
  
  base = package
    x: 1

  ok base.x is 1

# test 'empty packages'
# adding the empty package rule to the grammar won't work as is, need to figure that out.
