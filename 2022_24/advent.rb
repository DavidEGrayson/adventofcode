require 'set'

valley = File.foreach('input.txt').to_a.map(&:chomp)
empty_valley = valley.map { |line| line.gsub(/[><v^]/, '.') }
iwidth = valley[0].size - 2
iheight = valley.size - 2

# Generate all possible phases of the valley.
phase_count = iwidth.lcm(iheight)
$phases = phase_count.times.map { empty_valley.map(&:dup) }
puts "phase_count: #{phase_count}"
valley.size.times do |y|
  valley[y].size.times do |x|
    case valley[y][x]
    when 'v' then path = ->(time) { [x, 1 + (y - 1 + time) % iheight] }
    when '^' then path = ->(time) { [x, 1 + (y - 1 - time) % iheight] }
    when '>' then path = ->(time) { [1 + (x - 1 + time) % iwidth, y] }
    when '<' then path = ->(time) { [1 + (x - 1 - time) % iwidth, y] }
    else next
    end

    $phases.each_with_index do |phase, time|
      x2, y2 = path.call(time)
      phase[y2][x2] = 'B'
    end
  end
end

def possible_next_coords(time, coords)
  phase = $phases.fetch((time + 1) % $phases.size)
  x, y = coords
  candidates = [[x, y], [x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]]
  candidates.select do |coords|
    (phase[coords[1]] || '')[coords[0]] == '.'
  end
end

def find_path(time, start, goal)
  frontier = [ start ]
  while true
    new_frontier = Set.new
    return time if frontier.include?(goal)
    frontier.each do |coords|
      new_frontier.merge possible_next_coords(time, coords)
    end
    time += 1
    frontier = new_frontier
  end
end

valley_entrance = [valley.first.index('.'), 0]
valley_exit = [valley.last.index('.'), valley.size - 1]

time = find_path(0, valley_entrance, valley_exit)
puts "Part 1: #{time}"
time = find_path(time, valley_exit, valley_entrance)
time = find_path(time, valley_entrance, valley_exit)
puts "Part 2: #{time}"
