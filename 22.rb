# --- Day 22: Grid Computing ---
#
# You gain access to a massive storage cluster arranged in a grid;
# each storage node is only connected to the four nodes directly
# adjacent to it (three if the node is on an edge, two if it's in a
# corner).
#
# You can directly access data only on node /dev/grid/node-x0-y0, but
# you can perform some limited actions on the other nodes:
#
# - You can get the disk usage of all nodes (via df).  The result of
#   doing this is in your puzzle input.
# - You can instruct a node to move (not copy) all of its data to an
#   adjacent node (if the destination node has enough space to receive
#   the data).  The sending node is left empty after this operation.
#
# Nodes are named by their position: the node named node-x10-y10 is
# adjacent to nodes node-x9-y10, node-x11-y10, node-x10-y9, and
# node-x10-y11.
#
# Before you begin, you need to understand the arrangement of data on
# these nodes.  Even though you can only move data between directly
# connected nodes, you're going to need to rearrange a lot of the data
# to get access to the data you need.  Therefore, you need to work out
# how you might be able to shift data around.
#
# To do this, you'd like to count the number of viable pairs of nodes.
# A viable pair is any two nodes (A,B), regardless of whether they are
# directly connected, such that:
#
# - Node A is not empty (its Used is not zero).
# - Nodes A and B are not the same node.
# - The data on node A (its Used) would fit on node B (its Avail).
#
# How many viable pairs of nodes are there?

require "set"

class Node

  @@all = []
  def Node.all
    @@all
  end

  @@xmax, @@ymax = 0, 0
  def Node.xmax
    @@xmax
  end
  def Node.ymax
    @@ymax
  end

  attr_reader :x, :y, :size, :used

  def initialize(x, y, size, used)
    @x, @y, @size, @used = x, y, size, used
    @@all << self
    @@xmax = [@@xmax, x].max
    @@ymax = [@@ymax, y].max
  end

  def avail
    @size-@used
  end

end

open("22.in").readlines[2..-1].each do |l|
  /^\/dev\/grid\/node-x(\d+)-y(\d+) *(\d+)T *(\d+)T/.match(l)
  Node.new($1.to_i, $2.to_i, $3.to_i, $4.to_i)
end

puts Node.all.product(Node.all)
       .reject {|n1,n2| n1 == n2 }
       .select {|n1,n2| n1.used > 0 && n1.used <= n2.avail }
       .length

# --- Part Two ---
#
# Now that you have a better understanding of the grid, it's time to
# get to work.
#
# Your goal is to gain access to the data which begins in the node
# with y=0 and the highest x (that is, the node in the top-right
# corner).
#
# For example, suppose you have the following grid:
#
# Filesystem            Size  Used  Avail  Use%
# /dev/grid/node-x0-y0   10T    8T     2T   80%
# /dev/grid/node-x0-y1   11T    6T     5T   54%
# /dev/grid/node-x0-y2   32T   28T     4T   87%
# /dev/grid/node-x1-y0    9T    7T     2T   77%
# /dev/grid/node-x1-y1    8T    0T     8T    0%
# /dev/grid/node-x1-y2   11T    7T     4T   63%
# /dev/grid/node-x2-y0   10T    6T     4T   60%
# /dev/grid/node-x2-y1    9T    8T     1T   88%
# /dev/grid/node-x2-y2    9T    6T     3T   66%
#
# In this example, you have a storage grid 3 nodes wide and 3 nodes
# tall.  The node you can access directly, node-x0-y0, is almost full.
# The node containing the data you want to access, node-x2-y0 (because
# it has y=0 and the highest x value), contains 6 terabytes of data -
# enough to fit on your node, if only you could make enough space to
# move it there.
#
# Fortunately, node-x1-y1 looks like it has enough free space to
# enable you to move some of this data around.  In fact, it seems like
# all of the nodes have enough space to hold any node's data (except
# node-x0-y2, which is much larger, very full, and not moving any time
# soon).  So, initially, the grid's capacities and connections look
# like this:
#
# ( 8T/10T) --  7T/ 9T -- [ 6T/10T]
#     |           |           |
#   6T/11T  --  0T/ 8T --   8T/ 9T
#     |           |           |
#  28T/32T  --  7T/11T --   6T/ 9T
#
# The node you can access directly is in parentheses; the data you
# want starts in the node marked by square brackets.
#
# In this example, most of the nodes are interchangeable: they're full
# enough that no other node's data would fit, but small enough that
# their data could be moved around.  Let's draw these nodes as ..  The
# exceptions are the empty node, which we'll draw as _, and the very
# large, very full node, which we'll draw as #.  Let's also draw the
# goal data as G.  Then, it looks like this:
#
# (.) .  G
#  .  _  .
#  #  .  .
#
# The goal is to move the data in the top right, G, to the node in
# parentheses.  To do this, we can issue some commands to the grid and
# rearrange the data:
#
# - Move data from node-y0-x1 to node-y1-x1, leaving node node-y0-x1
#   empty:
#
#   (.) _  G
#    .  .  .
#    #  .  .
#
# - Move the goal data from node-y0-x2 to node-y0-x1:
#
#   (.) G  _
#    .  .  .
#    #  .  .
#
# - At this point, we're quite close.  However, we have no deletion
#   command, so we have to move some more data around.  So, next, we
#   move the data from node-y1-x2 to node-y0-x2:
#
#   (.) G  .
#    .  .  _
#    #  .  .
#
# - Move the data from node-y1-x1 to node-y1-x2:
#
#   (.) G  .
#    .  _  .
#    #  .  .
#
# - Move the data from node-y1-x0 to node-y1-x1:
#
#   (.) G  .
#    _  .  .
#    #  .  .
#
# - Next, we can free up space on our node by moving the data from
#   node-y0-x0 to node-y1-x0:
#
#   (_) G  .
#    .  .  .
#    #  .  .
#
# - Finally, we can access the goal data by moving it from
#   node-y0-x1 to node-y0-x0:
#
#   (G) _  .
#    .  .  .
#    #  .  .
#
# So, after 7 steps, we've accessed the data we want.  Unfortunately,
# each of these moves takes time, and we need to be efficient.
#
# What is the fewest number of steps required to move your goal data
# to node-x0-y0?
#
# --------------------
#
# This is a case where the puzzle, in its general form, would be
# extremely difficult to solve, but the characteristics of the input
# constrain it greatly.  As strongly hinted in the puzzle description,
# in our puzzle input:
#
# - There's a single empty node (_).
# - Many nodes (.) are "interchangeable" in that their data usage is
#   less than the empty node's size, and hence can in effect be
#   exchanged with the empty node.
# - No data can otherwise be moved between any interchangeable nodes.
# - A few "full" nodes (#) are too large to be exchanged with the
#   empty node, nor can any data otherwise be moved between them.
#
# Using the iconography above, and denoting the goal data with (G) and
# the target node with (*), our grid looks like this:
#
# *.....................................G
# .......................................
# .......................................
# .......................................
# .......................................
# .......................................
# .......................................
# .......................................
# .......................................
# .......................................
# .......................................
# .......................................
# .......................................
# .......................................
# .......................................
# .......................................
# .......................................
# .......................................
# .......................................
# ......#################################
# .......................................
# .......................................
# .......................................
# ............._.........................
# .......................................
#
# Given the constraints, this puzzle reduces to finding a path for the
# empty node to take, with the full nodes acting as a kind of wall.
# The only way to move the goal data leftward is to position the empty
# node to the immediate left of it and exchange.  This leaves the
# empty node to the right of the goal data, and so the empty node must
# walk around to the left side again, and in this way the goal data
# can be scootched along.
#
# From the diagram above an optimal path can be easily determined by
# hand, but what is amazing is that it can be found using an
# undirected path-finding algorithm given *only* the goal of having
# the goal data wind up at the target node.  Amazing because the
# scootching of the goal data along would seem to require some
# strategic thinking, yet it simply conforms to a shortest path.
#
# Run this program with a "visualize" command line argument to see the
# the empty node's movement animated (requires the curses gem).
#
# First, an unfortunate omission from the Ruby standard library...

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

class Array
  def x
    self[0]
  end
  def y
    self[1]
  end
end

$initial_empty = Node.all.find {|n| n.used == 0 }
$grid = Node.all
          .select {|n| n.used <= $initial_empty.size }
          .map {|n| [n.x,n.y] }
          .to_set

class State

  # A state records the locations of the empty node and goal data.

  attr_reader :empty, :goal

  def initialize(empty, goal)
    @empty, @goal = empty, goal
  end

  def final?
    @goal == [0,0]
  end

  def each_neighbor(&block)
    [[-1,0], [1,0], [0,-1], [0,1]].each do |dx,dy|
      n = [@empty.x+dx,@empty.y+dy]
      if $grid.member?(n)
        if n == @goal
          yield(State.new(@goal, @empty), 1)
        else
          yield(State.new(n, @goal), 1)
        end
      end
    end
  end

  def eql?(other)
    @empty == other.empty && @goal == other.goal
  end
  def hash
    [@empty, @goal].hash
  end

end

path = a_star_search(
  State.new([$initial_empty.x,$initial_empty.y], [Node.xmax,0]),
  lambda {|s| s.goal.x.abs+s.goal.y.abs })
puts path.length-1

if ARGV[0] == "visualize"

  require "curses"

  def draw(state)
    (0..Node.ymax).each do |y|
      Curses.addstr (0..Node.xmax).map {|x|
        case
        when !$grid.member?([x,y])
          "#"
        when [x,y] == state.empty
          "_"
        when [x,y] == state.goal
          "G"
        else
          "."
        end
      }.join + "\n"
    end
  end

  begin
    Curses.init_screen
    path.each do |s|
      Curses.clear
      Curses.setpos(0, 0)
      draw(s)
      Curses.refresh
      sleep(0.125)
    end
  ensure
    Curses.close_screen
  end

end
