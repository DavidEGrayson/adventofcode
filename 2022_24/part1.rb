require 'set'

valley = File.foreach('input.txt').to_a.map(&:chomp)
empty_valley = valley.map { |line| line.gsub(/[><v^]/, '.') }
iwidth = valley[0].size - 2
iheight = valley.size - 2

# Generate all possible phases of the valley.
phase_count = iwidth.lcm(iheight)
$phases = phase_count.times.map { empty_valley.map(&:dup) }
puts "phase_count: #{phase_count}"

# Make a lambda to represent the path of each blizzard.
valley.size.times do |y|
  valley[y].size.times do |x|
    char = valley[y][x]
    case char
    when 'v' then path = ->(time) { [x, 1 + (y - 1 + time) % iheight] }
    when '^' then path = ->(time) { [x, 1 + (y - 1 - time) % iheight] }
    when '>' then path = ->(time) { [1 + (x - 1 + time) % iwidth, y] }
    when '<' then path = ->(time) { [1 + (x - 1 - time) % iwidth, y] }
    else next
    end

    $phases.each_with_index do |phase, time|
      x2, y2 = path.call(time)
      phase[y2][x2] = char
    end
  end
end

def possible_next_coords(time, coords)
  phase = $phases.fetch((time + 1) % $phases.size)
  x, y = coords
  candidates = [[x, y], [x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]]
  candidates.select do |coords|
    phase[coords[1]][coords[0]] == '.'
  end
end

def manhattan_distance(coords1, coords2)
  (coords1[0] - coords2[0]).abs + (coords1[1] - coords2[1]).abs
end

# Do pathfinding with a priority queue.
# Each entry is an array with:
#   [0] = best_case_score: best possible total time to reach destination
#   [1] = time: the current time, modulo phase_count
#   [2] = coords: the current coordinates where we are
#   [3] = path: the path we used to get here, for debugging

puts $phases[3]
p possible_next_coords(2, [1, 2])

start = [valley.first.index('.'), 0]
goal = [valley.last.index('.'), valley.size - 1]
queue = [ [nil, 0, start, [start] ] ]
visited = Set.new
iteration_count = 0
while true
  bcs, time, coords, path = queue.shift

  visitation_state = [time, coords]
  if visited.include?(visitation_state)
    next
  end
  visited << visitation_state

  if (iteration_count % 10000) == 0
    puts "Analyzing time=#{time} coords=#{coords}, bcs=#{bcs}"
    puts "  queue.size=#{queue.size}"
  end

  if coords == goal
    p path
    puts time  # Success
    exit 0
  end

  next_time = time + 1
  possible_next_coords(time, coords).each do |next_coords|
    best_case_score = next_time + manhattan_distance(next_coords, goal)
    entry = [best_case_score, next_time, next_coords, path + [next_coords]]
    index = queue.each_index.find { |i| queue[i][0] > entry[0] } || queue.size
    queue.insert(index, entry)
  end

  iteration_count += 1
end
