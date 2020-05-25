# --- Day 21: Scrambled Letters and Hash ---
#
# The computer system you're breaking into uses a weird scrambling
# function to store its passwords.  It shouldn't be much trouble to
# create your own scrambled password so you can add it to the system;
# you just have to implement the scrambler.
#
# The scrambling function is a series of operations (the exact list is
# provided in your puzzle input).  Starting with the password to be
# scrambled, apply each operation in succession to the string.  The
# individual operations behave as follows:
#
# - swap position X with position Y means that the letters at indexes
#   X and Y (counting from 0) should be swapped.
# - swap letter X with letter Y means that the letters X and Y should
#   be swapped (regardless of where they appear in the string).
# - rotate left/right X steps means that the whole string should be
#   rotated; for example, one right rotation would turn abcd into
#   dabc.
# - rotate based on position of letter X means that the whole string
#   should be rotated to the right based on the index of letter X
#   (counting from 0) as determined before this instruction does any
#   rotations.  Once the index is determined, rotate the string to the
#   right one time, plus a number of times equal to that index, plus
#   one additional time if the index was at least 4.
# - reverse positions X through Y means that the span of letters at
#   indexes X through Y (including the letters at X and Y) should be
#   reversed in order.
# - move position X to position Y means that the letter which is at
#   index X should be removed from the string, then inserted such that
#   it ends up at index Y.
#
# For example, suppose you start with abcde and perform the following
# operations:
#
# - swap position 4 with position 0 swaps the first and last letters,
#   producing the input for the next step, ebcda.
# - swap letter d with letter b swaps the positions of d and b: edcba.
# - reverse positions 0 through 4 causes the entire string to be
#   reversed, producing abcde.
# - rotate left 1 step shifts all letters left one position, causing
#   the first letter to wrap to the end of the string: bcdea.
# - move position 1 to position 4 removes the letter at position 1
#   (c), then inserts it at position 4 (the end of the string): bdeac.
# - move position 3 to position 0 removes the letter at position 3
#   (a), then inserts it at position 0 (the front of the string):
#   abdec.
# - rotate based on position of letter b finds the index of letter b
#   (1), then rotates the string right once plus a number of times
#   equal to that index (2): ecabd.
# - rotate based on position of letter d finds the index of letter d
#   (4), then rotates the string right once, plus a number of times
#   equal to that index, plus an additional time because the index was
#   at least 4, for a total of 6 right rotations: decab.
#
# After these steps, the resulting scrambled password is decab.
#
# Now, you just need to generate a new scrambled password and you can
# access the system.  Given the list of scrambling operations in your
# puzzle input, what is the result of scrambling abcdefgh?

Operations = {

  "SWAPPOS" => lambda {|s,x,y|
                 t = s.clone
                 t[x], t[y] = t[y], t[x]
                 t
               },

  "SWAPLET" => lambda {|s,x,y|
                 Operations["SWAPPOS"].call(s, s.index(x), s.index(y))
               },

  "ROTLR" =>   lambda {|s,x,_|
                 t = " "*s.length
                 (0...s.length).each do |i|
                   t[(i+x)%s.length] = s[i]
                 end
                 t
               },

  "ROTBOP" =>  lambda {|s,x,_|
                 i = 1+s.index(x)
                 i += 1 if i >= 5
                 Operations["ROTLR"].call(s, i, nil)
               },

  "REVERSE" => lambda {|s,x,y|
                 s[0...x] + s[x..y].reverse + s[y+1..-1]
               },

  "MOVE" =>    lambda {|s,x,y|
                 t = s[0...x] + s[x+1..-1]
                 t.insert(y, s[x])
                 t
               }

}

Input = open("21.in").map {|l|
  if /swap position (\d+) with position (\d+)/.match(l)
    ["SWAPPOS", $1.to_i, $2.to_i]
  elsif /swap letter (\w) with letter (\w)/.match(l)
    ["SWAPLET", $1, $2]
  elsif /rotate (left|right) (\d+) steps?/.match(l)
    x = $2.to_i
    x = -x if $1 == "left"
    ["ROTLR", x, nil]
  elsif /rotate based on position of letter (\w)/.match(l)
    ["ROTBOP", $1, nil]
  elsif /reverse positions (\d+) through (\d+)/.match(l)
    ["REVERSE", $1.to_i, $2.to_i]
  elsif /move position (\d+) to position (\d+)/.match(l)
    ["MOVE", $1.to_i, $2.to_i]
  end
}

def scramble(s)
  Input.each do |op,x,y|
    s = Operations[op].call(s, x, y)
  end
  s
end

puts scramble("abcdefgh")

# --- Part Two ---
#
# You scrambled the password correctly, but you discover that you
# can't actually modify the password file on the system.  You'll need
# to un-scramble one of the existing passwords by reversing the
# scrambling process.
#
# What is the un-scrambled version of the scrambled password fbgdceah?
#
# --------------------
#
# The operations are all invertible, and hence we could run the
# scramble process in reverse.  (The little jog in the definition of
# the ROTBOP operation ensures that it is invertible.)  But there are
# only 8! permutations, so we just try them all, i.e., we mimic a
# real-world dictionary attack.

"abcdefgh".chars.permutation.each do |p|
  if scramble(p.join) == "fbgdceah"
    puts p.join
    break
  end
end
