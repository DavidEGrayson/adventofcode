$winds = File.read('input.txt').chomp.each_char.to_a
puts "Winds: #{$winds.size}"

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
  h = tower_height
  {
    next_shape_index: $next_shape_index,
    next_wind_index: $next_wind_index,
    top: $world[(h - 10)...h]
  }
end

def print_cycle_state
  h = tower_height
  puts "shape=#$next_shape_index wind=#$next_wind_index"
  puts "shapes=#$shape_count"
  puts "h=#{h}"
  10.times do |i|
    puts $world[h - i]
  end
  puts
end

def look_for_cycle
  $cycle_db ||= {}
  state = cycle_state
  last = $cycle_db[state]
  if last
    shape_count_change = $shape_count - last.fetch(:shape_count)
    height_change = tower_height - last.fetch(:height)
    shapes_remaining = $shape_count_goal - $shape_count
    cycle_count = shapes_remaining / shape_count_change

    return if cycle_count == 0

    puts "CYCLE!"
    print_cycle_state
    puts "shape_count_change: #{shape_count_change}"
    puts "height_change: #{height_change}"
    puts "Simulating #{cycle_count} cycles like this."

    $shape_count += cycle_count * shape_count_change
    $fake_height += cycle_count * height_change
    puts
  else
    $cycle_db[state] = { shape_count: $shape_count, height: tower_height }
  end
end

# max_sol_depth = -10  # Maximum soldification depth is actually 9.

$shape_count_goal = 1000000000000
$fake_height = 0

$shape_count = 0
while $shape_count < $shape_count_goal
  if $next_shape_index == 0
    look_for_cycle
    #print_cycle_state
  end

  shape = next_shape
  shape_width = shape.index("\n")
  x_range = (0..($width - shape_width))

  # Calculate starting coordinates.
  x = 2
  y = 3 + tower_height

  while true
    # Apply wind
    dir = { '<' => -1, '>' => 1 }.fetch(next_wind)
    if x_range.include?(dir + x) && !collision?(shape, x + dir, y)
      x += dir
    end

    # Fall if possible
    break if collision?(shape, x, y - 1)
    y -= 1

    #p [x, y]
  end

  # sol_depth = tower_height - y
  # if sol_depth > max_sol_depth
  #   max_sol_depth = sol_depth
  #   puts "max_sol_depth: #{sol_depth}"
  # end

  solidify(shape, x, y)
  $shape_count += 1
  #print_world
end

puts tower_height + $fake_height
