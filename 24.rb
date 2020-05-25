# --- Day 24: Air Duct Spelunking ---
#
# You've finally met your match; the doors that provide access to the
# roof are locked tight, and all of the controls and related
# electronics are inaccessible.  You simply can't reach them.
#
# The robot that cleans the air ducts, however, can.
#
# It's not a very fast little robot, but you reconfigure it to be able
# to interface with some of the exposed wires that have been routed
# through the HVAC system.  If you can direct it to each of those
# locations, you should be able to bypass the security controls.
#
# You extract the duct layout for this area from some blueprints you
# acquired and create a map with the relevant locations marked (your
# puzzle input).  0 is your current location, from which the cleaning
# robot embarks; the other numbers are (in no particular order) the
# locations the robot needs to visit at least once each.  Walls are
# marked as #, and open passages are marked as ..  Numbers behave like
# open passages.
#
# For example, suppose you have a map like the following:
#
# ###########
# #0.1.....2#
# #.#######.#
# #4.......3#
# ###########
#
# To reach all of the points of interest as quickly as possible, you
# would have the robot take the following path:
#
# - 0 to 4 (2 steps)
# - 4 to 1 (4 steps; it can't move diagonally)
# - 1 to 2 (6 steps)
# - 2 to 3 (2 steps)
#
# Since the robot isn't very fast, you need to find it the shortest
# route.  This path is the fewest steps (in the above example, a total
# of 14) required to start at 0 and then visit every other location at
# least once.
#
# Given your actual map, and starting from location 0, what is the
# fewest number of steps required to visit every non-0 number marked
# on the map at least once?

require "set"

$start = nil   # starting coordinates
$poi = Set.new # points of interest to visit

$map = open("24.in").each_with_index.flat_map {|l,y|
  l.chomp.chars.each_with_index.map {|c,x|
    if /[0-9]/.match(c)
      $poi.add(c)
      $start = [x,y] if c == "0"
    end
    [[x,y], c]
  }
}.to_h

# Copied from day 22...

class PriorityQueue

  def initialize
    @heap = [nil]
  end

  def push(priority, element)
    @heap << [priority, element]
    bubble_up(@heap.length-1)
  end

  def pop
    # returns the highest priority element
    @heap[1], @heap[-1] = @heap[-1], @heap[1]
    e = @heap.pop[1]
    bubble_down(1)
    e
  end

  def length
    @heap.length-1
  end

  private

  def bubble_up(i)
    p = i/2
    if i > 1 && @heap[p][0] < @heap[i][0]
      @heap[i], @heap[p] = @heap[p], @heap[i]
      bubble_up(p)
    end
  end

  def bubble_down(i)
    c = i*2
    if c < @heap.length
      c += 1 if c < @heap.length-1 && @heap[c+1][0] > @heap[c][0]
      if @heap[i][0] < @heap[c][0]
        @heap[i], @heap[c] = @heap[c], @heap[i]
        bubble_down(c)
      end
    end
  end

end

def a_star_search(start, heuristic)
  open = PriorityQueue.new
  open.push(0, start)
  cost = { start => 0 } # lowest cost discovered so far
  previous = { start => nil }
  while open.length > 0
    s = open.pop
    if s.final?
      path = []
      p = s
      while !p.nil?
        path << p
        p = previous[p]
      end
      return path.reverse
    end
    s.each_neighbor {|n,move_cost|
      c = cost[s] + move_cost
      if !cost.member?(n) || c < cost[n]
        cost[n] = c
        open.push(-(c+heuristic.call(n)), n)
        previous[n] = s
      end
    }
  end
  nil
end

class State

  # A state records the robot's position and the points of interest
  # visited so far.

  attr_reader :pos, :visited

  def initialize(pos, visited)
    @pos, @visited = pos, visited
  end

  def final?
    @visited.length == $poi.length
  end

  def each_neighbor(&block)
    [[-1,0], [1,0], [0,-1], [0,1]].each do |dx,dy|
      n = [@pos[0]+dx,@pos[1]+dy]
      # Fortunately the map is surrounded by walls, so the following
      # access will always be safe.
      next if $map[n] == "#"
      if $map[n] == "."
        yield(State.new(n, @visited), 1)
      else
        visited = @visited.clone
        visited.add($map[n])
        yield(State.new(n, visited), 1)
      end
    end
  end

  def eql?(other)
    @pos == other.pos && @visited == other.visited
  end
  def hash
    [@pos, @visited].hash
  end

end

def solve
  path = a_star_search(
    State.new($start, Set.new(["0"])),
    lambda {|s| $poi.length-s.visited.length })
  path.length-1
end

puts solve

# --- Part Two ---
#
# Of course, if you leave the cleaning robot somewhere weird, someone
# is bound to notice.
#
# What is the fewest number of steps required to start at 0, visit
# every non-0 number marked on the map at least once, and then return
# to 0?
#
# --------------------
#
# Sure enough, the additional constraint affects the shortest path.
# In the first part the visit order was 1-3-2-4-6-7-5, in this part,
# 1-3-2-6-7-5-4.

class State
  def final?
    @visited.length == $poi.length && @pos == $start
  end
end

puts solve
