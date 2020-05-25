# --- Day 25: Clock Signal ---
#
# You open the door and find yourself on the roof.  The city sprawls
# away from you for miles and miles.
#
# There's not much time now - it's already Christmas, but you're
# nowhere near the North Pole, much too far to deliver these stars to
# the sleigh in time.
#
# However, maybe the huge antenna up here can offer a solution.  After
# all, the sleigh doesn't need the stars, exactly; it needs the timing
# data they provide, and you happen to have a massive signal generator
# right here.
#
# You connect the stars you have to your prototype computer, connect
# that to the antenna, and begin the transmission.
#
# Nothing happens.
#
# You call the service number printed on the side of the antenna and
# quickly explain the situation.  "I'm not sure what kind of equipment
# you have connected over there," he says, "but you need a clock
# signal."  You try to explain that this is a signal for a clock.
#
# "No, no, a clock signal - timing information so the antenna computer
# knows how to read the data you're sending it.  An endless,
# alternating pattern of 0, 1, 0, 1, 0, 1, 0, 1, 0, 1...."  He trails
# off.
#
# You ask if the antenna can handle a clock signal at the frequency
# you would need to use for the data from the stars.  "There's no way
# it can!  The only antenna we've installed capable of that is on top
# of a top-secret Easter Bunny installation, and you're definitely
# not-"  You hang up the phone.
#
# You've extracted the antenna's clock signal generation assembunny
# code (your puzzle input); it looks mostly compatible with code you
# worked on just recently.
#
# This antenna code, being a signal generator, uses one extra
# instruction:
#
# - out x transmits x (either an integer or the value of a register)
#   as the next value for the clock signal.
#
# The code takes a value (via register a) that describes the signal to
# generate, but you're not sure how it's used.  You'll have to find
# the input to produce the right signal through experimentation.
#
# What is the lowest positive integer that can be used to initialize
# register a and cause the code to output a clock signal of 0, 1, 0,
# 1... repeating forever?
#
# --------------------
#
# Determining a program's infinite behavior would seem to require an
# analytic proof (the halting problem comes to mind).  But we can do
# so programmatically if the program has only a finite number of
# states, for then it must cycle.
#
# Note that a program that outputs a repeating pattern is not
# necessarily finite.  Consider:
#
# n = 0
# while true
#   output n%2
#   n += 1
# end
#
# But it so happens that our assembunny program is finite for all
# inputs.  And since it has only a single output instruction, we can
# simply capture the program state upon each output and watch for a
# cycle to appear.  (The program repeatedly outputs the reversed
# binary representation of a+633*4.)

Program = open("25.in").map {|l|
  /^(\w+) (?:([a-d])|(-?\d+))(?: (?:([a-d])|(-?\d+)))?$/.match(l)
  op = $1
  x = !$3.nil? ? $3.to_i : $2
  y = !$5.nil? ? $5.to_i : $4
  [op, x, y]
}

def run(initial_a, &block)
  # Yields the output value and register values to the associated block.
  reg = { "a" => initial_a, "b" => 0, "c" => 0, "d" => 0 }
  get = lambda {|o| o.class == String ? reg[o] : o }
  ip = 0
  while ip >= 0 && ip < Program.length
    op, x, y = Program[ip]
    case op
    when "cpy"
      reg[y] = get[x]
    when "inc"
      reg[x] += 1
    when "dec"
      reg[x] -= 1
    when "jnz"
      ip += get[y]-1 if get[x] != 0
    when "out"
      yield(get[x], reg["a"], reg["b"], reg["c"], reg["d"])
    end
    ip += 1
  end
end

def trial(initial_a)
  # We make a nonessential, but simplifying assumption that the first
  # state is repeated.
  first_state = nil
  output = []
  run(initial_a) {|o,a,b,c,d|
    if first_state.nil?
      first_state = [a, b, c, d]
    else
      if [a, b, c, d] == first_state
        return !!/^(01)+$/.match(output.join)
      end
    end
    output << o
  }
end

0.step do |a|
  if trial(a)
    puts a
    break
  end
end

# --- Part Two ---
#
# The antenna is ready.  Now, all you need are the fifty stars
# required to generate the signal for the sleigh, but you don't have
# enough.
#
# You look toward the sky in desperation... suddenly noticing that a
# lone star has been installed at the top of the antenna!  Only 49
# more to go.

puts "DONE!"
