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
        appendRaw(b2, <<002, 003>>)
        %{__struct__: ByteBuffer, buffer: <<000, 001, 002, 003>>, debug: true}
  """
  def appendRaw(buffer, data) do
    %ByteBuffer{data: buffer.data <> data, debug: buffer.debug}
  end
  
  @doc """
  Appends bytes to a bytebuffer. Returns a new ByteBuffer.  Delimits inserted data with '{' and '}' if we pass a debug buffer

  ## Parameters
  - `buffer` - a byte buffer struct
  - `bytes`  - bytes to append. Can also be a String.

  ## Examples
  	b1 = %ByteBuffer{data: "hello", debug: false}
        appendBytes(b1, " world")
        %{__struct__: ByteBuffer, buffer: "hello world", debug: false}

  	b2 = %ByteBuffer{data: <<000, 001>>, debug: true}
        appendBytes(b2, <<002, 003>>)
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

  @doc """
  Convert hex string into bytes and append it to ByteBuffer
  ## Parameters
  - `buffer` - a byte buffer struct
  - `bytes`  - bytes to append. Can also be a String.

  ## Examples
  	b1 = %ByteBuffer{data: "hello", debug: false}
        appendHex(b1, "FF01")
        %ByteBuffer{data: <<104, 101, 108, 108, 111, 255, 1>>, debug: false}

  	b2 = %ByteBuffer{data: <<000, 001>>, debug: true}
        appendHex(b2, "FF01")
        %ByteBuffer{data: <<0, 1, 123, 255, 1, 125>>, debug: true}

  """
  def appendHex(buffer, hs) do
    case Base.decode16(hs) do
      {:ok, value}     -> buffer |> appendBytes(value)
      {:error, reason} -> "Invalid hex string: #{reason}"
      other            -> "An unknown error occurred: #{other}"
    end
  end
end
