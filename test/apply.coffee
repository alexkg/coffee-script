# system works, just need to add a few more tests...

test "application (and curried application) associates to the left", ->
  out = CoffeeScript.compile "a <- b, c <- d", bare:on
  eq out, 'a(b, c)(d);'

test "application with no arguments corresponds to bare function call", ->
  out = CoffeeScript.compile "a <-", bare:on
  eq out, 'a();'

  out = CoffeeScript.compile "(a <-)", bare:on
  eq out, 'a();'

  out = CoffeeScript.compile "[a <-]", bare:on
  eq out, '[a()];'

test "currying with no arguments and no receiver is a syntax error", ->
  throws (-> CoffeeScript.compile "a <~"), "throws syntax error"

test "currying with no arguments returns the function bound to the receiver", ->
  o = {'thing', toString: -> @thing}
  s = o.toString <~
  eq o.toString(), s()

test "currying with no receiver just partially applies the function", ->
  
test "currying with a receiver and arguments binds and partially applies the function", ->

test "indentation determines call nesting", ->
  out = CoffeeScript.compile """
  a <-
    b <-
      c <- d, e <- f
      g <- h, j <- k
    l <- m, n,
      o <- p
      q <- r
  """, bare:on
  eq out, 'a(b(c(d, e)(f), g(h, j)(k)), l(m, n, o(p), q(r)));'

test "can handle splats", ->
  
test "compatible with post if, for, etc", ->

