defmodule ByteBufferTest do
  use ExUnit.Case
  doctest ByteBuffer

  test "appendRaw to string" do
    b1 = %ByteBuffer{data: "hello", debug: false}
    assert ByteBuffer.appendRaw(b1, " world") == %{__struct__: ByteBuffer, data: "hello world", debug: false}
    b2 = %ByteBuffer{data: <<000, 001>>, debug: true}
    assert ByteBuffer.appendRaw(b2, <<002, 003>>) == %{__struct__: ByteBuffer, data: <<000, 001, 002, 003>>, debug: true}
  end

  test "appendbytes" do
    b1 = %ByteBuffer{data: "hello", debug: false}
    assert ByteBuffer.appendBytes(b1, " world") == %{__struct__: ByteBuffer, data: "hello world", debug: false}
  end

  test "appendbytes with debug delimiters" do
    b2 = %ByteBuffer{data: <<000, 001>>, debug: true}
    assert ByteBuffer.appendBytes(b2, <<002, 003>>) == %ByteBuffer{data: <<0, 1, 123, 2, 3, 125>>, debug: true}

    b3 = %ByteBuffer{data: "ab", debug: true}
    assert ByteBuffer.appendBytes(b3, "cd") == %ByteBuffer{data: "ab{cd}", debug: true}
  end

end
