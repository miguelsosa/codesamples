defmodule FizzbuzzTest do
  use ExUnit.Case
  doctest Fizzbuzz

  test "not multiple of 3 or 5" do
    assert Fizzbuzz.fizzbuzz(1) == 1
    assert Fizzbuzz.fizzbuzz(2) == 2
    assert Fizzbuzz.fizzbuzz(4) == 4
  end

  test "multiple of 3" do
    assert Fizzbuzz.fizzbuzz(3) == :Fizz
    assert Fizzbuzz.fizzbuzz(6) == :Fizz
    assert Fizzbuzz.fizzbuzz(9) == :Fizz
  end

  test "multiple of 5" do
    assert Fizzbuzz.fizzbuzz(5)  == :Buzz
    assert Fizzbuzz.fizzbuzz(10) == :Buzz
    assert Fizzbuzz.fizzbuzz(20) == :Buzz
  end

  test "multiple of 15" do
    assert Fizzbuzz.fizzbuzz(15) == :FizzBuzz
    assert Fizzbuzz.fizzbuzz(30) == :FizzBuzz
  end

  test "seq of 15" do
    assert Fizzbuzz.seq(0) == []
    assert Fizzbuzz.seq(1) == [1]
    assert Fizzbuzz.seq(2) == [1, 2]
    assert Fizzbuzz.seq(3) == [1, 2, :Fizz]
    assert Fizzbuzz.seq(15) == [1, 2, :Fizz, 4, :Buzz, :Fizz, 7, 8, :Fizz, :Buzz, 11, :Fizz, 13, 14, :FizzBuzz]
  end

end
