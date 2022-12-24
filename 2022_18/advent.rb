require 'set'

$drop = Set.new
File.foreach('input.txt') do |line|
  coords = line.split(',').map(&:to_i).freeze
  $drop << coords if coords.size == 3
end

$exterior = Set.new([[0, 0, 0]])  # confirmed exterior air
$interior = Set.new               # confirmed interior air

def adjacent_coords(c)
  [
    [c[0] + 1, c[1],     c[2]    ],
    [c[0] - 1, c[1],     c[2]    ],
    [c[0],     c[1] + 1, c[2]    ],
    [c[0],     c[1] - 1, c[2]    ],
    [c[0],     c[1],     c[2] + 1],
    [c[0],     c[1],     c[2] - 1],
  ]
end

# Tries to find an air-only path from the specified coordinates to [0, 0, 0].
# Returns true on success, false on failure.
def exterior?(coords)
  return false if $drop.include?(coords) || $interior.include?(coords)
  return true if $exterior.include?(coords)
  #puts "Pathfinding for #{c}"
  visited = Set.new
  queue = [[0, coords]]
  while !queue.empty?
    _, current = queue.shift
    next if visited.include?(current) || $drop.include?(current)
    break if $interior.include?(current)
    if $exterior.include?(current)
      $exterior |= visited
      return true
    end
    adjacent_coords(current).each do |a|
      next if visited.include?(a) || $drop.include?(current)
      min_distance = a.map(&:abs).sum
      index = queue.each_index.find { |i| queue[i][0] > min_distance } || queue.size
      queue.insert(index, [min_distance, a])
    end
    visited << current
  end
  $interior |= visited
  false
end

area = 0
$drop.each do |c|
  adjacent_coords(c).each do |a|
    area += 1 if exterior?(a)
  end
end
puts area

raise 'wtf1' if !($exterior & $interior).empty?
raise 'wtf2' if !($exterior & $drop).empty?
raise 'wtf3' if !($interior & $drop).empty?

# Uncomment to visualize:
# (-2..24).each do |z|
#   puts "z=#{z}"
#   (-2..24).each do |y|
#     (-2..24).each do |x|
#       coords = [x, y, z]
#       print case
#       when $drop.include?(coords) then 'D'
#       when $exterior.include?(coords) then 'x'
#       when $interior.include?(coords) then 'i'
#       else '.'
#       end
#     end
#     puts
#   end
#   gets
# end
