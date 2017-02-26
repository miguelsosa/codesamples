
# Tail call optimized fibbonacci

def fib(n)
  def tcofib(v1, v2, n)
    acc = v1 + v2
    (n == 0) ? acc : tcofib(v2, acc, n - 1)
  end
  n < 2 ?  1 : tcofib(1, 1, n-2)
end
