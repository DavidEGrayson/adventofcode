$winds = File.read('input.txt').chomp.each_char.to_a

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

$width = 7
$world = []

def tower_height
  y = 0
  y += 1 while $world[y] && $world[y].include?('#')
  y
end

def print_world
  $world[0...tower_height].reverse_each do |world|
    puts world
  end
  puts
end

def expand_world(height)
  $world << '.' * 7 while $world.size < height
end

def solidify(shape, x, y)
  shape.each_line.with_index do |line, yi|
    line.each_char.with_index do |char, xi|
      $world[y + yi][x + xi] = '#' if char == '#'
    end
  end
end

def collision?(shape, x, y)
  if y < 0
    # ground collision
    raise "Too many rows were culled!" if $culled_height > 0
    return true
  end
  shape.each_line.with_index do |line, yi|
    line.each_char.with_index do |char, xi|
      return true if char == '#' && $world[y + yi][x + xi] == '#'
    end
  end
  false
end

def next_wind
  r = $winds[$next_wind_index ||= 0]
  $next_wind_index = ($next_wind_index + 1) % $winds.size
  r
end

def next_shape
  r = $shapes[$next_shape_index ||= 0]
  $next_shape_index = ($next_shape_index + 1) % $shapes.size
  r
end

def cycle_state
  {
    next_shape_index: $next_shape_index,
    next_wind_index: $next_wind_index,
    top: $world.map(&:dup),
  }
end

def look_for_cycle
  $cycle_db ||= {}
  state = cycle_state
  last = $cycle_db[state]
  if last
    shape_count_change = $shape_count - last.fetch(:shape_count)
    height_change = (tower_height + $culled_height) - last.fetch(:height)
    shapes_remaining = $shape_count_goal - $shape_count
    cycle_count = shapes_remaining / shape_count_change

    return if cycle_count == 0

    puts "CYCLE FOUND! Current state:"
    puts "shape=#$next_shape_index wind=#$next_wind_index"
    print_world
    puts "Since the last time this state was seen:"
    puts "  Shape count increased by #{shape_count_change}"
    puts "  Tower height increased by #{height_change}"
    puts "Simulating #{cycle_count} cycles like this."
    puts

    $shape_count += cycle_count * shape_count_change
    $culled_height += cycle_count * height_change
  else
    $cycle_db[state] = { shape_count: $shape_count, height: tower_height + $culled_height }
  end
end

$shape_count_goal = 1000000000000
$culled_height = 0

$shape_count = 0
while $shape_count < $shape_count_goal
  look_for_cycle if $next_shape_index == 0

  shape = next_shape
  shape_width = shape.index("\n")
  x_range = (0..($width - shape_width))

  x = 2
  y = 3 + tower_height

  expand_world(y + 4)

  while true
    # Apply wind.
    dir = { '<' => -1, '>' => 1 }.fetch(next_wind)
    if x_range.include?(x + dir) && !collision?(shape, x + dir, y)
      x += dir
    end

    # Fall if possible
    break if collision?(shape, x, y - 1)
    y -= 1
  end

  solidify(shape, x, y)
  $shape_count += 1

  # Cull rows at the bottom that cannot be reached anymore to keep things
  # running fast and simplify the cycle_state calculation.
  # The 'collision?' method will raise an exception if those rows were actually
  # needed.
  while tower_height > 40
    $world.shift
    $culled_height += 1
  end
end

puts tower_height + $culled_height
