# --- Day 20: Firewall Rules ---
#
# You'd like to set up a small hidden computer here so you can use it
# to get back into the network later.  However, the corporate firewall
# only allows communication with certain external IP addresses.
#
# You've retrieved the list of blocked IPs from the firewall, but the
# list seems to be messy and poorly maintained, and it's not clear
# which IPs are allowed.  Also, rather than being written in
# dot-decimal notation, they are written as plain 32-bit integers,
# which can have any value from 0 through 4294967295, inclusive.
#
# For example, suppose only the values 0 through 9 were valid, and
# that you retrieved the following blacklist:
#
# 5-8
# 0-2
# 4-7
#
# The blacklist specifies ranges of IPs (inclusive of both the start
# and end value) that are not allowed.  Then, the only IPs that this
# firewall allows are 3 and 9, since those are the only numbers not in
# any range.
#
# Given the list of blocked IPs you retrieved from the firewall (your
# puzzle input), what is the lowest-valued IP that is not blocked?
#
# --------------------
#
# The input ranges overlap.  We compute the union of blocked IPs as a
# list of disjoint ranges, then look at the complement.

a = open("20.in").map {|l| l.scan(/\d+/).map(&:to_i) }
a.sort! {|l,r| l[0] <=> r[0] }

# consolidate overlapping and adjacent ranges
i = 0
while i < a.length-1
  if a[i][1] < a[i+1][0]-1
    i += 1
  else
    a[i][1] = [a[i][1], a[i+1][1]].max
    a.delete_at(i+1)
  end
end

if a[0][0] == 0
  puts a[0][1]+1
else
  puts 0
end

# --- Part Two ---
#
# How many IPs are allowed by the blacklist?

puts a[0][0]-0 +
     (0...a.length-1).map {|i| a[i+1][0]-a[i][1]-1 }.reduce(:+) +
     4294967295-a[-1][1]
