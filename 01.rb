# --- Day 1: No Time for a Taxicab ---
#
# Santa's sleigh uses a very high-precision clock to guide its
# movements, and the clock's oscillator is regulated by stars.
# Unfortunately, the stars have been stolen... by the Easter Bunny.
# To save Christmas, Santa needs you to retrieve all fifty stars by
# December 25th.
#
# Collect stars by solving puzzles.  Two puzzles will be made
# available on each day in the Advent calendar; the second puzzle is
# unlocked when you complete the first.  Each puzzle grants one star.
# Good luck!
#
# You're airdropped near Easter Bunny Headquarters in a city
# somewhere.  "Near," unfortunately, is as close as you can get - the
# instructions on the Easter Bunny Recruiting Document the Elves
# intercepted start here, and nobody had time to work them out
# further.
#
# The Document indicates that you should start at the given
# coordinates (where you just landed) and face North.  Then, follow
# the provided sequence: either turn left (L) or right (R) 90 degrees,
# then walk forward the given number of blocks, ending at a new
# intersection.
#
# There's no time to follow such ridiculous instructions on foot,
# though, so you take a moment and work out the destination.  Given
# that you can only walk on the street grid of the city, how far is
# the shortest path to the destination?
#
# For example:
#
# - Following R2, L3 leaves you 2 blocks East and 3 blocks North, or 5
#   blocks away.
# - R2, R2, R2 leaves you 2 blocks due South of your starting
#   position, which is 2 blocks away.
# - R5, L5, R5, R3 leaves you 12 blocks away.
#
# How many blocks away is Easter Bunny HQ?

require "set"

def walk(&block)
  # yields each coordinate encountered
  dirs = [[0,1], [-1,0], [0,-1], [1,0]] # N, W, S, E
  x, y, d = 0, 0, 0
  yield(x, y)
  open("01.in").read().split(", ").each do |cmd|
    if cmd[0] == "L"
      d = (d+1)%4
    else
      d = (d-1)%4
    end
    cmd[1..-1].to_i.times do
      x += dirs[d][0]
      y += dirs[d][1]
      yield(x, y)
    end
  end
end

puts to_enum(:walk).to_a.last.map(&:abs).reduce(:+)

# --- Part Two ---
#
# Then, you notice the instructions continue on the back of the
# Recruiting Document.  Easter Bunny HQ is actually at the first
# location you visit twice.
#
# For example, if your instructions are R8, R4, R4, R8, the first
# location you visit twice is 4 blocks away, due East.
#
# How many blocks away is the first location you visit twice?

seen = Set.new
walk {|x,y|
  if seen.member?([x,y])
    puts x.abs+y.abs
    break
  end
  seen.add([x,y])
}
