$winds = File.read('input.txt').chomp.each_char.to_a

$width = 7
$world = []

def print_world
  $world.reverse_each do |world|
    puts world
  end
  puts
end

def tower_height
  y = 0
  y += 1 while $world[y] && $world[y].include?('#')
  y
end

def expand_world(height)
  $world << '.' * 7 while $world.size < height
end

def solidify(shape, x, y)
  expand_world(y + 4)
  shape.each_line.with_index do |line, yi|
    line.each_char.with_index do |char, xi|
      $world[y + yi][x + xi] = '#' if char == '#'
    end
  end
end

def collision?(shape, x, y)
  return true if y < 0  # ground collision
  expand_world(y + 4)
  shape.each_line.with_index do |line, yi|
    line.each_char.with_index do |char, xi|
      return true if char == '#' && $world[y + yi][x + xi] == '#'
    end
  end
  false
end

$shapes = []
$shapes << "####\n"
$shapes << <<END
.#.
###
.#.
END
$shapes << <<END  # upside down on purpose
###
..#
..#
END
$shapes << <<END
#
#
#
#
END
$shapes << <<END
##
##
END

$wind_enum = $winds.cycle
$shape_enum = $shapes.cycle

2022.times do |i|

  shape = $shape_enum.next
  shape_width = shape.index("\n")
  x_range = (0..($width - shape_width))

  # Calculate starting coordinates.
  x = 2
  y = 3 + tower_height

  while true
    # Apply wind
    dir = { '<' => -1, '>' => 1 }.fetch($wind_enum.next)
    if x_range.include?(dir + x) && !collision?(shape, x + dir, y)
      x += dir
    end

    # Fall if possible
    break if collision?(shape, x, y - 1)
    y -= 1

    #p [x, y]
  end

  solidify(shape, x, y)
  #print_world
end

puts tower_height

# WRONG: 3323
