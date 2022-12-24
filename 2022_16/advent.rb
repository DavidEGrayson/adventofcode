require 'set'

$valve_rates = {}
$tunnels = {}
File.foreach('input.txt') do |line|
  md = line.match(/Valve (\w\w) has flow rate=(\d+); tunnels? leads? to valves? (.*)/)
  if md
    name = md[1].to_sym
    rate = md[2].to_i
    $valve_rates[name] = rate if rate != 0
    $tunnels[name] = md[3].split(', ').map(&:to_sym)
  else
    raise "Syntax error: #{line}"
  end
end
$valves = $valve_rates.keys

def calculate_distances(start_room)
  distance = 0
  frontier = [start_room]
  visited = Set.new
  $distances[start_room] = {}
  while !frontier.empty?
    new_frontier = []
    frontier.each do |room|
      if $valve_rates[room] && room != start_room
        $distances[start_room][room] = distance
      end
      visited << room
      $tunnels[room].each do |adjacent_room|
        new_frontier << adjacent_room if !visited.include?(adjacent_room)
      end
    end
    frontier = new_frontier
    distance += 1
  end
end

$distances = {}
calculate_distances(:AA)
$valves.each do |valve|
  calculate_distances(valve)
end

def solve(time_left, room, open_valves, score)
  open_valves = open_valves.select do |valve|
    $distances[room][valve] + 2 <= time_left
  end
  best_score = score
  open_valves.each do |valve|
    rec_time_left = time_left - ($distances[room][valve] + 1)
    rec_open_valves = open_valves - [valve]
    rec_score = score + rec_time_left * $valve_rates[valve]
    candidate_score = solve(rec_time_left, valve, rec_open_valves, rec_score)
    best_score = candidate_score if candidate_score > best_score
  end
  best_score
end

part1_score = solve(30, :AA, $valves, 0)
puts "Part 1: #{part1_score}"

# Part 2: Iterate over every possible division of work between me and elephant.
best_score = 0
(0...(1 << $valves.size)).each do |bitmask|
  my_valves = []
  elephant_valves = []
  $valves.each_index do |i|
    (bitmask[i] == 0 ? my_valves : elephant_valves) << $valves[i]
  end
  # puts "#{my_valves} : #{elephant_valves}"
  score = solve(26, :AA, my_valves, 0) + solve(26, :AA, elephant_valves, 0)
  best_score = score if score > best_score
end
puts "Part 2: #{best_score}"
