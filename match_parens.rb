
def group_check(s)
  opened = []
  pairs = {
    '{' => '}',
    '(' => ')',
    '[' => ']'
  }
  
  s.each_char do |c|
    if pairs.key?(c)
      opened.push(c)

    elsif pairs.(c) && opened.pop != pairs[c]
      return false
    end
  end
  return opened.empty?
end

# Poor man's unit tests:

def test (res)
  puts res ? "passed" : "failed"
end

test group_check("{}") == true
test group_check("()") == true
test group_check("[]") == true

test group_check("{}([])") == true
test group_check("{}([])") == true
test group_check("{[{}[]()[]{}{}{}{}{}{}()()()()()()()()]{{{[[[((()))]]]}}}}(())[[]]{{}}[][][][][][][]({[]})") == true
test group_check("") == true

# incorrect number of opens and closes
test group_check("{") == false
test group_check("[{}{}())") == false
test group_check("{})") == false
test group_check("([]))") == false

# correct number of opens and closes, but incorrect order
test group_check("{(})") == false
