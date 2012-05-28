compact = (out) ->
  out = out.replace /[\s;]/g, ''

join = (xs...) -> xs.join ' '

test "application (and curried application) associates to the left", ->
  out = compact CoffeeScript.compile "f <- x, y <- z", bare:on
  eq out, 'f(x,y(z))'

test "application with no arguments corresponds to bare function call", ->
  out = compact CoffeeScript.compile "f <-", bare:on
  eq out, 'f()'

  out = compact CoffeeScript.compile "(f <-)", bare:on
  eq out, 'f()'

  out = compact CoffeeScript.compile "[f <-, 5]", bare:on
  eq out, '[f(),5]'

  out = compact CoffeeScript.compile "send 4, f <-, 5", bare:on
  eq out, "send(4,f(),5)"

test "currying with no arguments and no receiver returns the function reapplied", ->
  f = (x) -> x + 1000
  g = f <~
  eq f(666), g(666)
  ok f isnt g

test "currying with no arguments returns the function bound to the receiver", ->
	goon = 
	  status: 'drunk'
	  toString: -> @status

	status = goon.toString <~
	eq status <-, 'drunk'

test "currying with no receiver just partially applies the function", ->
  f = join <~ 'a', 'b'
  eq 'a b c', f 'c'
  
test "currying with a receiver and arguments binds and partially applies the function", ->
	xs = []
	append = xs.push <~ 1, 2, 3
	append 4, 5, 6
	arrayEq xs, [1,2,3,4,5,6]

test "indentation determines call nesting", ->
  out = compact CoffeeScript.compile """
  a <-
    b <-
      c <- d, e <- f
      g <- h, j <- k
    l <- m, n,
      o <- p
      q <- r
  """, bare:on
  eq out, 'a(b(c(d,e(f)),g(h,j(k))),l(m,n,o(p),q(r)))'

test "form equivalence", ->
  inline = compact CoffeeScript.compile """
  f <- x, y <- z
  """, bare:on

  block = compact CoffeeScript.compile """
  f <-
    x
    y <- z
  """, bare:on

  eq inline, block
  
test "compatible with splats", ->
	sum = (args...) ->
	  args.reduce (x, y) -> x + y

	f = sum <~ 1, 2
	g = f <~ [3, 4]..., 1
	eq 11, g <-
	eq 111, g <- 100
  
test "compatible with post if", ->
  out = compact CoffeeScript.compile """
  return f <- 1,2 if b
  """, bare:on
  eq out, "if(b){returnf(1,2)}"
  
  out = compact CoffeeScript.compile """
  return f <- if b then 1 else 2
  """, bare:on
  eq out, "returnf(b?1:2)"

test "receiver binding compatible with @", ->
  o =
    thing: 'thing'
    toString: -> @thing
    getToString: -> @toString <~
  
  s = o.getToString <-
  eq o.toString <-, s <-

test "currying a call to `call`", ->
  f = (-> @thing).call <~ (thing: 'umbrella')
  eq f <-, 'umbrella'

  queue = new ->
    @length = 0
    @push = Array.prototype.push.call <~ @
    @pull = Array.prototype.shift.call <~ @
    this

  queue.push 1, 2, 3
  eq 1, queue.pull <-
  eq 2, queue.pull <-
  eq 3, queue.pull <-

test "can be used to bind class methods", ->
  ID = (x) -> x

  class Collection
    @map = (f, coll) ->
      result = @zero <-
      @each <-
        (e, i) => @cons result, f(e, i), i
        coll
      result

  class Hash extends Collection
    @zero = -> {}
    @cons = (coll, e, i) -> coll[i] = e
    @each = (f, coll) ->
      f <- e, i for i, e of coll
      undefined

  # Though the implementation of @map uses @zero, @cons, and @each,
  # it can be isolated and used independently:
  copy = Hash.map <~ ID

  original = a:1
  impostor = copy original

  eq original.toString(), impostor.toString()
  ok original isnt impostor
