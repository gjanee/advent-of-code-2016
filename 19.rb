# --- Day 19: An Elephant Named Joseph ---
#
# The Elves contact you over a highly secure emergency channel.  Back
# at the North Pole, the Elves are busy misunderstanding White
# Elephant parties.
#
# Each Elf brings a present.  They all sit in a circle, numbered
# starting with position 1.  Then, starting with the first Elf, they
# take turns stealing all the presents from the Elf to their left.  An
# Elf with no presents is removed from the circle and does not take
# turns.
#
# For example, with five Elves (numbered 1 to 5):
#
#   1
# 5   2
#  4 3
#
# - Elf 1 takes Elf 2's present.
# - Elf 2 has no presents and is skipped.
# - Elf 3 takes Elf 4's present.
# - Elf 4 has no presents and is also skipped.
# - Elf 5 takes Elf 1's two presents.
# - Neither Elf 1 nor Elf 2 have any presents, so both are skipped.
# - Elf 3 takes Elf 5's three presents.
#
# So, with five Elves, the Elf that sits starting in position 3 gets
# all the presents.
#
# With the number of Elves given in your puzzle input, which Elf gets
# all the presents?
#
# --------------------
#
# This is a game of elimination, not present counting.  The
# elimination is very regular, and elves need not be individually
# represented.  If the number of elves is even, then in a cycle every
# other elf is eliminated and the "stride" between adjacent elves is
# doubled.  If the number of elves is odd, same thing, but a
# wraparound effect causes the first elf to shift.

Input = 3014387

f, s, n = 1, 1, Input # first, stride, count
while n > 1
  s *= 2
  f += s if n%2 == 1
  n /= 2
end
puts f

# --- Part Two ---
#
# Realizing the folly of their present-exchange rules, the Elves agree
# to instead steal presents from the Elf directly across the circle.
# If two Elves are across the circle, the one on the left (from the
# perspective of the stealer) is stolen from.  The other rules remain
# unchanged: Elves with no presents are removed from the circle
# entirely, and the other elves move in slightly to keep the circle
# evenly spaced.
#
# For example, with five Elves (again numbered 1 to 5):
#
# - The Elves sit in a circle; Elf 1 goes first:
#
#     1
#   5   2
#    4 3
#
# - Elves 3 and 4 are across the circle; Elf 3's present is stolen,
#   being the one to the left.  Elf 3 leaves the circle, and the rest
#   of the Elves move in:
#
#     1           1
#   5   2  -->  5   2
#    4 -          4
#
# - Elf 2 steals from the Elf directly across the circle, Elf 5:
#
#     1         1
#   -   2  -->     2
#     4         4
#
# - Next is Elf 4 who, choosing between Elves 1 and 2, steals from
#   Elf 1:
#
#    -          2
#       2  -->
#    4          4
#
# - Finally, Elf 2 steals from Elf 4:
#
#    2
#       -->  2
#    -
#
# So, with five Elves, the Elf that sits starting in position 2 gets
# all the presents.
#
# With the number of Elves given in your puzzle input, which Elf now
# gets all the presents?
#
# --------------------
#
# This part is trickier.  If the number of elves is a multiple of
# three, then in each triple of elves the first two are eliminated;
# but if not, the pattern of eliminations is not so regular.  We
# create a circular array of elves and manually eliminate them by
# setting them to nil.  To simplify the logic and to avoid having to
# jump over previously-eliminated elves, before wrapping around the
# array we remove nils using Ruby's Array#compact method.

a = (1..Input).to_a # elves
i = 0               # index of current elf
while a.length > 1
  l = a.length      # remaining elves
  k = 0             # number eliminated
  while true
    a[(i+l/2+k)%a.length] = nil
    next_i = (i+1)%a.length
    break if a[next_i].nil?
    i = next_i
    l -= 1
    k += 1
  end
  last_elf = a[i]
  a.compact!
  i = (a.index(last_elf)+1)%a.length
end
puts a[0]
