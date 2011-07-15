# I'm not sure how to test these.
# CoffeeScript.compile doesn't recognise <-, which means it doesn't
# reflect the current changes.
# What is shown below is the output of the compiled compiler.

test "left association", ->
# a <- b, c <- d
#
# => a(b, c)(d);

test "nested arguments are sent to the parent term", ->
# a <-
#   b <-
#     c <- d, e <- f
#     g <- h, j <- k
#   l <- m, n,
#     o <- p
#     q <- r
#
# => a(b(c(d, e)(f), g(h, j)(k)), l(m, n, o(p), q(r)));