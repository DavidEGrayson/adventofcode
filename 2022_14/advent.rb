$width = 1000
$height = 200
$world = (' ' * $width + "\n") * $height

def coords_in_bounds?(coords)
  (0...$width).include?(coords[0]) && (0...$height).include?(coords[1])
end

def read(coords)
  raise if !coords_in_bounds?(coords)
  $world[coords[1] * ($width + 1) + coords[0]]
end

def draw(coords, char)
  raise if !coords_in_bounds?(coords)
  $world[coords[1] * ($width + 1) + coords[0]] = char
end

def draw_rock_line(start, dest)
  start = start.dup
  while true
    draw(start, '#')
    if start[0] < dest[0]
      start[0] += 1
    elsif start[0] > dest[0]
      start[0] -= 1
    elsif start[1] < dest[1]
      start[1] += 1
    elsif start[1] > dest[1]
      start[1] -= 1
    else
      break
    end
  end
end

# NOT NEEDED TO SOLVE THE PROBLEM.  This is just for testing the slow/naive way.
def add_sand(start)
  coords = start
  while true
    grain_fell = false

    support_coords = [
      [coords[0], coords[1] + 1],
      [coords[0] - 1, coords[1] + 1],
      [coords[0] + 1, coords[1] + 1],
    ]
    support_coords.each do |sc|
      return false if !coords_in_bounds?(sc)
      if read(sc) == ' '
        coords = sc
        grain_fell = true
        break
      end
    end

    if !grain_fell
      draw(coords, 'o')
      return true
    end
  end
end

# NOT NEEDED TO SOLVE THE PROBLEM.  This is just for testing the slow/naive way.
def slow_fill(coords)
  while read(coords) == ' '
    add_sand(coords) or return
  end
end

# Fast recursive function that tries to place a sand grain at the specified
# point by recursively filling the three spots in the row below that support it.
# Returns true if successful.
def fill(coords)
  x, y = coords
  if !coords_in_bounds?(coords)
    false
  elsif '#o'.include?(read(coords))
    true
  elsif fill([x, y + 1]) && fill([x - 1, y + 1]) && fill([x + 1, y + 1])
    draw(coords, 'o')
    true
  else
    draw(coords, '~')
    false
  end
end

File.foreach('input.txt') do |line|
  coord_strings = line.split(' -> ')
  coords = nil
  coord_strings.each do |coord_string|
    next_coords = coord_string.split(',').map(&:to_i)
    raise if next_coords.size != 2
    draw_rock_line(coords, next_coords) if coords
    coords = next_coords
  end
end

# Part 2, with hardcoded floor height.
draw_rock_line([0, 184], [$width - 1, 184])

# fill([500, 0])
slow_fill([500, 0])

$world.each_line { |line| puts line[450..600] }

puts $world.count('o')
