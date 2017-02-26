defmodule Fibonacci do
  @moduledoc """
  Tail recursive fibbonacci implementation using elixir. Returns the full sequence up to (n).
  """
  def fib(n) do
    do_fib(0, 1, n, [])
  end

  defp do_fib(_, _, n, _) when n < 0 do
    {:error, "Number must be positive to calculate fibonnaci sequence"}
  end

  defp do_fib(v1, _, 0, l) do
    l |> Enum.reverse
  end

  defp do_fib(v1, v2, n, l) do
    do_fib(v2, v1+v2, n-1, [v2 | l])
  end
end
