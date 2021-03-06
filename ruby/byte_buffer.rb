# ByteBuffer builder class

class ByteBuffer
  include Enumerable
  @debug

  def initialize(&block)
    @buffer = StringIO.new
    @debug = false
    self.instance_eval(&block) unless block.nil?
  end

  def appendRaw(b)
    puts "append Raw called with: #{b}"
    @buffer.write(b)
  end

  def appendBytes(b)
    appendRaw('{') if @debug
    appendRaw(b)
    appendRaw('}') if @debug
  end

  def appendHex(hs)
    # convert hex string into bytes and append it
    appendBytes([hs].pack('H*'))
  end

  def appendNumber(n, nbytes)
    fmt = "%0#{nbytes}x"
    bytestr = [format(fmt, n)].pack('H*')
    puts "bytestr (#{bytestr.length}) = #{bytestr.unpack('H*')}"  if @debug
    appendBytes(bytestr)
  end

  def appendShort(n)
    appendNumber(n, 4)
  end

  def appendInt(n)
    appendNumber(n, 8)
  end

  def appendLong(n)
    appendNumber(n, 16)
  end

  def appendUTF(s)
    e = s.force_encoding("utf-8")
    appendRaw("UTF_LENGTH:") if @debug
    appendShort(e.length)
    appendRaw("UTF_DATA:") if @debug
    appendBytes(e)
  end

  def to_s
    @buffer.string
  end

  def buffer
    @buffer
  end

  def hexstr
    @buffer.string.unpack('H*')[0].upcase
  end

  def length
    @buffer.length
  end

  def clear
    @buffer.truncate(0)
    @buffer.rewind
  end

  def finish
    @buffer.close
    to_s
  end

  # Implement enumerable
  def each(&block)
    @buffer.rewind.each{|e| block.call(e)}
  end

  def start_debug
    puts "start debug called"
    @debug = true
  end

  def end_debug
    puts "end debug called"
    @debug = false
  end

end

