# --- Day 23: Safe Cracking ---
#
# This is one of the top floors of the nicest tower in EBHQ.  The
# Easter Bunny's private office is here, complete with a safe hidden
# behind a painting, and who wouldn't hide a star in a safe behind a
# painting?
#
# The safe has a digital screen and keypad for code entry.  A sticky
# note attached to the safe has a password hint on it: "eggs".  The
# painting is of a large rabbit coloring some eggs.  You see 7.
#
# When you go to type the code, though, nothing appears on the
# display; instead, the keypad comes apart in your hands, apparently
# having been smashed.  Behind it is some kind of socket - one that
# matches a connector in your prototype computer!  You pull apart the
# smashed keypad and extract the logic circuit, plug it into your
# computer, and plug your computer into the safe.
#
# Now, you just need to figure out what output the keypad would have
# sent to the safe.  You extract the assembunny code from the logic
# chip (your puzzle input).
#
# The code looks like it uses almost the same architecture and
# instruction set that the monorail computer used!  You should be able
# to use the same assembunny interpreter for this as you did there,
# but with one new instruction:
#
# tgl x toggles the instruction x away (pointing at instructions like
# jnz does: positive means forward; negative means backward):
#
# - For one-argument instructions, inc becomes dec, and all other
#   one-argument instructions become inc.
# - For two-argument instructions, jnz becomes cpy, and all other
#   two-argument instructions become jnz.
# - The arguments of a toggled instruction are not affected.
# - If an attempt is made to toggle an instruction outside the
#   program, nothing happens.
# - If toggling produces an invalid instruction (like cpy 1 2) and an
#   attempt is later made to execute that instruction, skip it
#   instead.
# - If tgl toggles itself (for example, if a is 0, tgl a would target
#   itself and become inc a), the resulting instruction is not
#   executed until the next time it is reached.
#
# For example, given this program:
#
# cpy 2 a
# tgl a
# tgl a
# tgl a
# cpy 1 a
# dec a
# dec a
#
# - cpy 2 a initializes register a to 2.
# - The first tgl a toggles an instruction a (2) away from it, which
#   changes the third tgl a into inc a.
# - The second tgl a also modifies an instruction 2 away from it,
#   which changes the cpy 1 a into jnz 1 a.
# - The fourth line, which is now inc a, increments a to 3.
# - Finally, the fifth line, which is now jnz 1 a, jumps a (3)
#   instructions ahead, skipping the dec a instructions.
#
# In this example, the final value in register a is 3.
#
# The rest of the electronics seem to place the keypad entry (the
# number of eggs, 7) in register a, run the code, and then send the
# value left in register a to the safe.
#
# What value should be sent to the safe?

program = open("23.in").map {|l|
  /^(\w+) (?:([a-d])|(-?\d+))(?: (?:([a-d])|(-?\d+)))?$/.match(l)
  op = $1
  x = !$3.nil? ? $3.to_i : $2
  y = !$5.nil? ? $5.to_i : $4
  [op, x, y]
}

reg = { "a" => 7, "b" => 0, "c" => 0, "d" => 0 }

def reg?(operand)
  operand.class == String
end

get = lambda {|o| reg?(o) ? reg[o] : o }

ip = 0
while ip >= 0 && ip < program.length
  op, x, y = program[ip]
  case op
  when "cpy"
    reg[y] = get[x] if reg?(y)
  when "inc"
    reg[x] += 1 if reg?(x)
  when "dec"
    reg[x] -= 1 if reg?(x)
  when "jnz"
    ip += get[y]-1 if get[x] != 0
  when "tgl"
    i = ip+get[x]
    if i >= 0 && i < program.length
      p = program[i]
      if ["inc", "dec", "tgl"].member?(p[0])
        p[0] = (p[0] == "inc" ? "dec" : "inc")
      else
        p[0] = (p[0] == "jnz" ? "cpy" : "jnz")
      end
    end
  end
  ip += 1
end

puts reg["a"]

# --- Part Two ---
#
# The safe doesn't open, but it does make several angry noises to
# express its frustration.
#
# You're quite sure your logic is working correctly, so the only other
# thing is... you check the painting again.  As it turns out, colored
# eggs are still eggs.  Now you count 12.
#
# As you run the program with this new input, the prototype computer
# begins to overheat.  You wonder what's taking so long, and whether
# the lack of any instruction more powerful than "add one" has
# anything to do with it.  Don't bunnies usually multiply?
#
# Anyway, what value should actually be sent to the safe?
#
# --------------------
#
# We reverse engineer the program to understand what it's doing, and
# find that register a holds the input value and serves as the
# accumulator; register b is a counter that counts down from a-1 to 1;
# and registers c and d are temporary.  The first part of the program
# uses three nested loops to compute a!:
#
# cpy a b   | b = a
# dec b     | b -= 1                          b = a-1
# cpy a d   | d = a     <-------------------+
# cpy 0 a   | a = 0                         |
# cpy b c   | c = b     <----------+        |
# inc a     | a += 1    <-+        |        |
# dec c     | c -= 1      |        |        |
# jnz c -2  | if c != 0 --+ a += b |        |
# dec d     | d -= 1               |        |
# jnz d -5  | if d != 0 -----------+ a *= b |
# dec b     | b -= 1                 b -= 1 |
# cpy b c   | c = b                         |
# cpy c d   | d = c                         |
# dec d     | d -= 1    <-+                 |
# inc c     | c += 1      |                 |
# jnz d -2  | if d != 0 --+ c = b*2         |
# tgl c     |                               |
# cpy -16 c | c = -16                       |
# jnz 1 c   | always    --------------------+ a = a!
#
# The toggle instruction updates the instruction b*2 beyond itself.
# Initially this is beyond the end of the program, but as b is
# decremented the toggle instruction begins to have effect, changing
# inc instructions to dec instructions.  Finally, when b = 1, the
# critical jump instruction that computes the factorial is changed to
# a (useless) copy instruction, and the program falls through to the
# end:
#
# tgl c       tgl c     |
# cpy -16 c   cpy -16 c | c = -16
# jnz 1 c  => cpy 1 c   | c = 1
# cpy 85 c    cpy 85 c  | c = 85
# jnz 92 d => cpy 92 d  | d = 92    <-----------+
# inc a       inc a     | a += 1    <-+         |
# inc d    => dec d     | d -= 1      |         |
# jnz d -2    jnz d -2  | if d != 0 --+ a += 92 |
# inc c    => dec c     | c -= 1                |
# jnz c -5    jnz c -5  | if c != 0 ------------+ a += 85*92
#
# Thus, the program computes a! + 85*92.

puts (1..12).reduce(:*) + 85*92
