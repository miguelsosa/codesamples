# A non traditional fizzbuzz implementation. FizzBuzzType generates
# the appropriate value based on the fizzbuzz rules. It stores the
# value and a printable version of the value which it generates on
# initialization.
# 
#    t = FizzBuzzType.new(2)
#    #<FizzBuzzType:0x007fa8440c4308 @value=2, @printable="2">
#    t = FizzBuzzType.new(3)
#    #<FizzBuzzType:0x007fa8458232b0 @value=3, @printable="Fizz">
#    t = FizzBuzzType.new(4)
#    #<FizzBuzzType:0x007fa845841558 @value=4, @printable="4">
#    t = FizzBuzzType.new(5)
#    #<FizzBuzzType:0x007fa845861f38 @value=5, @printable="Buzz">
#    t = FizzBuzzType.new(15)
#    #<FizzBuzzType:0x007fa84587b488 @value=15, @printable="FizzBuzz">

class FizzBuzzType
  def initialize(n)
    @value = n
    set_printable(n)
  end

  def to_s
    printable
  end

  private
  attr_accessor :value, :printable
  def set_printable(n)
    @printable = ''
    @printable += 'Fizz' if (value % 3) == 0
    @printable += 'Buzz' if (value % 5) == 0
    @printable = @value.to_s if @printable.empty?
  end
end

# A different fizzbuzz implementation. It stores the fizzbuzz value
# directly. It does not store the numeric value
#
#    t = Fizzbuzz.new(2)
#    #<Fizzbuzz:0x007fa845893150 @val=2>
#    t = Fizzbuzz.new(5)
#    #<Fizzbuzz:0x007fa8458388b8 @val="Buzz">
#    t = Fizzbuzz.new(10)
#    #<Fizzbuzz:0x007fa845831450 @val="Buzz">
#    t = Fizzbuzz.new(15)
#    #<Fizzbuzz:0x007fa845829cc8 @val="FizzBuzz">

class Fizzbuzz
    Fizz = 'Fizz'
    Buzz = 'Buzz'
    Fizzbuzz = 'FizzBuzz'

    def initialize(n)
      @val = if    (n % 15) == 0 ; Fizzbuzz
             elsif (n %  3) == 0 ; Fizz
             elsif (n %  5) == 0 ; Buzz
             else                ; n
      end
    end

    def to_s
      @val.to_s
    end
end

def main

  puts " before work:  #{`ps -o rss= -p #{Process.pid}`.to_i} K "
  GC.disable

  puts "Fizzbuzz:     " + (1..16).collect {|n| Fizzbuzz.new(n).to_s }.join(' ')
  puts "FizzBuzzType: " + (1..16).collect {|n| FizzBuzzType.new(n).to_s }.join(' ')

  puts " after work:  #{`ps -o rss= -p #{Process.pid}`.to_i} K "
  GC.enable
end

def test (res)
  puts res ? "passed" : "failed"
end

test Fizzbuzz.new(1).to_s == '1'
test Fizzbuzz.new(2).to_s == '2'
test Fizzbuzz.new(3).to_s == Fizzbuzz::Fizz
test Fizzbuzz.new(5).to_s == Fizzbuzz::Buzz
test Fizzbuzz.new(9).to_s == Fizzbuzz::Fizz
test Fizzbuzz.new(10).to_s == Fizzbuzz::Buzz
test Fizzbuzz.new(15).to_s == Fizzbuzz::Fizzbuzz
test Fizzbuzz.new(18).to_s == Fizzbuzz::Fizz
test Fizzbuzz.new(20).to_s == Fizzbuzz::Buzz
test Fizzbuzz.new(30).to_s == Fizzbuzz::Fizzbuzz
 
puts "test fizz buzz type FizzBuzzType.new(1).to_s == #{FizzBuzzType.new(1).to_s}"
 
test FizzBuzzType.new(1).to_s == '1'
test FizzBuzzType.new(2).to_s == '2'
test FizzBuzzType.new(3).to_s == Fizzbuzz::Fizz
test FizzBuzzType.new(5).to_s == Fizzbuzz::Buzz
test FizzBuzzType.new(9).to_s == Fizzbuzz::Fizz
test FizzBuzzType.new(10).to_s == Fizzbuzz::Buzz
test FizzBuzzType.new(15).to_s == Fizzbuzz::Fizzbuzz
test FizzBuzzType.new(18).to_s == Fizzbuzz::Fizz
test FizzBuzzType.new(20).to_s == Fizzbuzz::Buzz
test FizzBuzzType.new(30).to_s == Fizzbuzz::Fizzbuzz
 
main()
