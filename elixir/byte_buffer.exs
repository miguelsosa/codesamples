defmodule ByteBuffer do
  @moduledoc """
  Defines a bytebuffer struct and helper functions to building a byte
  buffer from basic data types.
  """

  @doc """
  Buffer structure. data
  """
  defstruct data: <<>>, debug: false

  @doc """
  Concatenate 2 byte buffers. Returns a new ByteBuffer.

  ## Parameters
  - `buffer` - a byte buffer struct
  - `data` - data to append

  ## Examples
  	b1 = %ByteBuffer{data: "hello", debug: false}
        appendRaw(b1, " world")
        %{__struct__: ByteBuffer, buffer: "hello world", debug: false}

  	b2 = %ByteBuffer{data: <<000, 001>>, debug: true}
        appendRaw(b1, <<002, 003>>)
        %{__struct__: ByteBuffer, buffer: <<000, 001, 002, 003>>, debug: true}
  """
  def appendRaw(buffer, data) do
    %ByteBuffer{data: buffer.data <> data, debug: buffer.debug}
  end
  
  @doc """
  Appends bytes to a bytebuffer. Returns a new ByteBuffer.  Insert

  ## Parameters
  - `buffer` - a byte buffer struct
  - `bytes`  - bytes to append. Can also be a String.

  ## Examples
  	b1 = %ByteBuffer{data: "hello", debug: false}
        appendBytes(b1, " world")
        %{__struct__: ByteBuffer, buffer: "hello world", debug: false}

  	b2 = %ByteBuffer{data: <<000, 001>>, debug: true}
        appendBytes(b1, <<002, 003>>)
        %ByteBuffer{data: <<1, 2, 123, 3, 4, 125>>, debug: true}
  """
  def appendBytes(%ByteBuffer{debug: true} = buffer, data ) do
    buffer
    |> appendRaw("{")
    |> appendRaw(data)
    |> appendRaw("}") 
  end

  def appendBytes(buffer, data) do
    buffer
    |> appendRaw(data)
  end
end
