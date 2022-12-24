$width = 1000
$height = 200
world = (' ' * $width + "\n") * $height

def coords_in_bounds?(coords)
  (0..$width).include?(coords[0]) && (0..$height).include?(coords[1])
end

def read(world, coords)
  raise if !coords_in_bounds?(coords)
  world[coords[1] * ($width + 1) + coords[0]]
end

def draw(world, coords, char)
  raise if !coords_in_bounds?(coords)
  world[coords[1] * ($width + 1) + coords[0]] = char
end

def draw_rock_line(world, start, dest)
  start = start.dup
  while true
    draw(world, start, '#')
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

def support_coords_for(coords)
  [
    [coords[0], coords[1] + 1],
    [coords[0] - 1, coords[1] + 1],
    [coords[0] + 1, coords[1] + 1],
  ]
end

def simulate_grain_falling(world, start, path_char, dest_char)
  coords = start
  while coords_in_bounds?(coords)
    draw(world, coords, path_char) if path_char
    grain_fell = false
    support_coords_for(coords).each do |candidate_coords|
      if read(world, candidate_coords) == ' '
        coords = candidate_coords
        grain_fell = true
        break
      end
    end

    if !grain_fell
      draw(world, coords, dest_char) if dest_char
      return
    end
  end
end

File.foreach('input.txt') do |line|
  coord_strings = line.split(' -> ')
  coords = nil
  coord_strings.each do |coord_string|
    next_coords = coord_string.split(',').map(&:to_i)
    raise if next_coords.size != 2
    draw_rock_line(world, coords, next_coords) if coords
    coords = next_coords
  end
end

# Write 'a' on some of the spots that a grain of sand destined for the abyss
# cannot travel through.

# Assumption: Bottom line is entirely spaces so skip it.
# Assumption: Left and right columns are entirely spaces so skip them.
($height - 2).downto(0) do |y|
  1.upto($width - 2) do |x|
    spot = read(world, [x, y])
    next if spot != ' '
    below_mid = read(world, [x, y + 1])
    next if below_mid == ' '
    below_left = read(world, [x - 1, y + 1])
    below_right = read(world, [x + 1, y + 1])
    if below_left != ' ' && below_right != ' '
      draw(world, [x, y], 'a')
    end
  end
end

# Write '~' on the path we think the final grain will take.
simulate_grain_falling(world, [500, 0], '~', nil)

# Write 'o' on all the spots that have to be filled with sand for the final
# grain to take that path.
0.upto($height - 2) do |y|
  1.upto($width - 2) do |x|
    spot = read(world, [x, y])
    if spot == '~' || spot == 'o'
      support_coords_for([x, y]).each do |support_coords|
        support = read(world, support_coords)
        break if support == '~'
        draw(world, support_coords, 'o') if support != '#'
      end
    end
  end
end

world.each_line { |line| puts line[450..600] }

puts world.count('o')
