defmodule Fizzbuzz do
  @moduledoc """
  Documentation for Fizzbuzz.
  """

  @doc """
  Fizzbuzz

  ## Examples

      iex> Fizzbuzz.fizzbuzz(1)
      1

      iex> Fizzbuzz.fizzbuzz(3)
      :Fizz

      iex> Fizzbuzz.fizzbuzz(4)
      4

      iex> Fizzbuzz.fizzbuzz(5)
      :Buzz

      iex> Fizzbuzz.fizzbuzz(7)
      7

      iex> Fizzbuzz.fizzbuzz(15)
      :FizzBuzz

      iex> Fizzbuzz.fizzbuzz(16)
      16

  """
  def fizzbuzz(n) when rem(n, 15) == 0 do
    :FizzBuzz
  end

  def fizzbuzz(n) when rem(n, 3) == 0 do
    :Fizz
  end

  def fizzbuzz(n) when rem(n, 5) == 0 do
    :Buzz
  end

  def fizzbuzz(n) do
    n
  end

  def seq(n) do
    do_seq([], n)
  end

  defp do_seq(s, 0) do
    s
  end

  defp do_seq(s, n) do
    do_seq([fizzbuzz(n)|s], n - 1)
  end
end
