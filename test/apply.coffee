compact = (out) ->
  out = out.replace(/(\w)[\s]+(\W)/gm, "$1$2")
  out = out.replace(/(\W)[\s]+(\W)/gm, "$1$2")
  out = out.replace(/(\W)[\s]+(\w)/gm, "$1$2")
  out = out.replace(/;/g, "")

sum = (xs) -> xs.reduce (x,y) -> x+y 

join = (xs...) -> xs.join ' '

test "application (and curried application) associates to the left", ->
  out = compact CoffeeScript.compile "f <- x,y <- z", bare:on
  eq out, 'f(x,y)(z)'

test "application with no arguments corresponds to bare function call", ->
  out = compact CoffeeScript.compile "f <-", bare:on
  eq out, 'f()'

  out = compact CoffeeScript.compile "(f <-)", bare:on
  eq out, 'f()'

  out = compact CoffeeScript.compile "[f <-, 5]", bare:on
  eq out, '[f(),5]'

  out = compact CoffeeScript.compile "send 4, f <-, 5", bare:on
  eq out, "send(4,f(),5)"

test "currying with no arguments and no receiver is a syntax error", ->
  throws (-> CoffeeScript.compile "f <~"), "throws syntax error"

test "currying with no arguments returns the function bound to the receiver", ->
  o = {'thing', toString: -> @thing}
  s = o.toString <~
  eq o.toString(), s <-

test "currying with no receiver just partially applies the function", ->
  f = join <~ 'a', 'b'
  eq 'a b c', f 'c'
  
test "currying with a receiver and arguments binds and partially applies the function", ->
  o = x:'nicto', join: ((xs...) -> join xs..., @x)
  f = o.join <~ 'clatto'
  g = f <~ 'verata'
  eq 'clatto verata nicto', g <-

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
  eq out, 'a(b(c(d,e)(f),g(h,j)(k)),l(m,n,o(p),q(r)))'

test "compatible with splats", ->
  sum = (args...) -> args.reduce (x,y) -> x+y
  g = sum <~ [1,2]..., 3
  eq 15, g <- [4,5]...
  
test "compatible with post if", ->
  out = compact CoffeeScript.compile """
  return f <- 1,2 if b
  """, bare:on
  eq out, "if(b){return f(1,2)}"
  
  out = compact CoffeeScript.compile """
  return f <- if b then 1 else 2
  """, bare:on
  eq out, "return f(b?1:2)"

test "compatible with @", ->
  o =
    thing: 'thing'
    toString: -> @thing
    getToString: -> @toString <~
  
  s = o.getToString()
  eq o.toString(), s <-

test "compatible with nested functions", ->
  out = compact CoffeeScript.compile """
  ->
    ->
      result <- if b then x <- 5 else y <- 9
  """, bare:on
  eq out, "(function(){return function(){return result(b?x(5):y(9))}})"