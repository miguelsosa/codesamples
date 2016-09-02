#require 'rails_helper'
require './byte_buffer'

RSpec.describe "ByteBuffer" do

  before do
    @b = ByteBuffer.new
  end

  context "data" do
    # Hmm not sure if these are relevant. These are accesses to
    # underlying data structure which prevents us from changing the
    # internals.  Since the implementation internals should not be
    # important, then perhaps we should not even have tests (or calls)
    # for this.

    it "returns a StringIO object when buffer is called" do
      expect(@b.buffer).to be_kind_of(StringIO) 
    end

    it "returns content as a string when finish is called" do
      val = "somedata"
      @b.appendRaw(val)
      expect(@b.finish).to eq(val)
    end

    it "can't write to it after finish is called" do
      val = "somedata"
      @b.appendRaw(val)
      ignore = @b.finish
      expect{@b.appendRaw(val)}.to raise_error(IOError)
    end

    it "returns the string value even after finish is called" do
      val = "somedata"
      @b.appendRaw(val)
      ignore = @b.finish
      expect(@b.to_s).to eq(val)
    end
  end


  context "empty" do
    it "starts empty" do
      expect(@b.length).to eq(0)
      expect(@b.to_s).to eq("")
    end

    it "clear returns it to empty state" do
      @b.appendInt(1)
      expect(@b.length).to_not eq(0)
      @b.clear
      expect(@b.length).to eq(0)
    end
  end

  context "full" do
    it "has a length of the bytes inserted when appendRaw" do
      @b.appendRaw("1")
      expect(@b.length).to eq(1)
    end

    it "has a length of the bytes inserted when appendBytes and not in debug" do
      @b.appendBytes("1")
      expect(@b.length).to eq(1)
    end

    it "can append hex values as bytes" do
      @b.appendHex("00FF")
      expect(@b.length).to eq(2)
    end

    it "appends 2 bytes with appendShort" do
      @b.appendShort(12)
      expect(@b.length).to eq(2)
      expect(@b.hexstr).to eq("000C")
    end

    it "appends 4 bytes with appendInt" do
      @b.appendInt(12)
      expect(@b.length).to eq(4)
      expect(@b.hexstr).to eq("0000000C")
    end

    it "appends 8 bytes with appendLong" do
      @b.appendLong(12)
      expect(@b.length).to eq(8)
      expect(@b.hexstr).to eq("000000000000000C")
    end

    it "appends 2 byte string length fllowed by UTF encoded string bytes with appendUTF" do
      @b.appendUTF("four")
      expect(@b.length).to eq(6)
      expect(@b.hexstr).to eq("0004666F7572")
    end

    it "can append multiple times with different appenders" do
      @b.appendUTF("four")
      encodedFour = "0004666F7572"
      @b.appendShort(1)
      encodedShort1 = "0001"
      expect(@b.length).to eq(8)
      expect(@b.hexstr).to eq("#{encodedFour}#{encodedShort1}")
    end
  end

  context "debug" do
    it "starts off in non-debug mode" do
      val = "a string"
      @b.appendBytes(val)
      expect(@b.to_s).to_not include('{')
      expect(@b.to_s).to_not include('}')
    end

    it "wraps elements in debug tags when string is added after debug is started" do
      val = "a string"
      @b.start_debug
      @b.appendBytes(val)
      res = '{' + val + '}'
      expect(@b.to_s).to eq(res)
    end

    it "can switch debugging mode on and off" do
      v = ["one", "two", "three"]
      @b.start_debug
      @b.appendBytes(v[0])
      @b.end_debug
      @b.appendBytes(v[1])
      @b.start_debug
      @b.appendBytes(v[2])
      res = '{' + v[0] + '}' + v[1] + '{' + v[2] + '}'
      expect(@b.to_s).to eq(res)
    end

    it "can initialize with a block" do
      v = ["one", "two", "three"]
      from_block = ByteBuffer.new do 
        start_debug
        appendBytes(v[0])
        end_debug
        appendBytes(v[1])
        start_debug
        appendBytes(v[2])
      end
      res = '{' + v[0] + '}' + v[1] + '{' + v[2] + '}'
      expect(from_block.to_s).to eq(res)
    end
        
  end
end
