# --- Day 8: Two-Factor Authentication ---
#
# You come across a door implementing what you can only assume is an
# implementation of two-factor authentication after a long game of
# requirements telephone.
#
# To get past the door, you first swipe a keycard (no problem; there
# was one on a nearby desk).  Then, it displays a code on a little
# screen, and you type that code on a keypad.  Then, presumably, the
# door unlocks.
#
# Unfortunately, the screen has been smashed.  After a few minutes,
# you've taken everything apart and figured out how it works.  Now you
# just have to work out what the screen would have displayed.
#
# The magnetic strip on the card you swiped encodes a series of
# instructions for the screen; these instructions are your puzzle
# input.  The screen is 50 pixels wide and 6 pixels tall, all of which
# start off, and is capable of three somewhat peculiar operations:
#
# - rect AxB turns on all of the pixels in a rectangle at the top-left
#   of the screen which is A wide and B tall.
# - rotate row y=A by B shifts all of the pixels in row A (0 is the
#   top row) right by B pixels.  Pixels that would fall off the right
#   end appear at the left end of the row.
# - rotate column x=A by B shifts all of the pixels in column A (0 is
#   the left column) down by B pixels.  Pixels that would fall off the
#   bottom appear at the top of the column.
#
# For example, here is a simple sequence on a smaller screen:
#
# - rect 3x2 creates a small rectangle in the top-left corner:
#
#   ###....
#   ###....
#   .......
#
# - rotate column x=1 by 1 rotates the second column down by one
#   pixel:
#
#   #.#....
#   ###....
#   .#.....
#
# - rotate row y=0 by 4 rotates the top row right by four pixels:
#
#   ....#.#
#   ###....
#   .#.....
#
# - rotate column x=1 by 1 again rotates the second column down by one
#   pixel, causing the bottom pixel to wrap back to the top:
#
#   .#..#.#
#   #.#....
#   .#.....
#
# As you can see, this display technology is extremely powerful, and
# will soon dominate the tiny-code-displaying-screen market.  That's
# what the advertisement on the back of the display tries to convince
# you, anyway.
#
# There seems to be an intermediate check of the voltage used by the
# display: after you swipe your card, if the screen did work, how many
# pixels should be lit?

Input = open("08.in").readlines
W, H = 50, 6

def process
  screen = H.times.map { [false]*W }
  yield(screen) if block_given?
  Input.each do |l|
    if /rect (\d+)x(\d+)/.match(l)
      w, h = Regexp.last_match[1].to_i, Regexp.last_match[2].to_i
      (0...h).each do |y|
        (0...w).each do |x|
          screen[y][x] = true
        end
      end
    elsif /rotate row y=(\d+) by (\d+)/.match(l)
      y, s = Regexp.last_match[1].to_i, Regexp.last_match[2].to_i
      old = screen[y].clone
      (0...W).each do |x|
        screen[y][(x+s)%W] = old[x]
      end
    elsif /rotate column x=(\d+) by (\d+)/.match(l)
      x, s = Regexp.last_match[1].to_i, Regexp.last_match[2].to_i
      old = screen.map {|row| row[x] }
      (0...H).each do |y|
        screen[(y+s)%H][x] = old[y]
      end
    end
    yield(screen) if block_given?
  end
  screen
end

puts process.map {|row| row.count(true) }.reduce(:+)

# --- Part Two ---
#
# You notice that the screen is only capable of displaying capital
# letters; in the font it uses, each letter is 5 pixels wide and 6
# tall.
#
# After you swipe your card, what code is the screen trying to
# display?
#
# --------------------
#
# Run this program with a "visualize" command line argument to see the
# evolution of the screen graphically (requires the curses gem).  It's
# magical to start with solid blocks of on pixels and arrive at
# letters.  Judging from the instructions, our guess is Eric Wastl
# started from letters and generated inverse instructions to cluster
# and then turn off blocks of pixels in the top left corner, then
# reversed and inverted the instructions.

def format_row(row)
  row.map {|v| v ? "#" : "." }.join
end

if ARGV[0] == "visualize"

  require "curses"
  begin
    Curses.init_screen
    process {|screen|
      Curses.clear
      Curses.setpos(0, 0)
      screen.each do |row|
        Curses.addstr(format_row(row) + "\n")
      end
      Curses.refresh
      sleep(0.125)
    }
  ensure
    Curses.close_screen
  end

else

  process.each do |row|
    puts format_row(row)
  end

end
