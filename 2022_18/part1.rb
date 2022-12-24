require 'set'

$drop_set = Set.new
File.foreach('input.txt') do |line|
  coords = line.split(',').map(&:to_i).freeze
  $drop_set << coords if coords.size == 3
end

area = 0
$drop_set.each do |d|
  adjacent_coords = [
    [d[0] + 1, d[1],     d[2]    ],
    [d[0] - 1, d[1],     d[2]    ],
    [d[0],     d[1] + 1, d[2]    ],
    [d[0],     d[1] - 1, d[2]    ],
    [d[0],     d[1],     d[2] + 1],
    [d[0],     d[1],     d[2] - 1],
  ]

  adjacent_coords.each do |c|
    area +=1 if !$drop_set.include?(c)
  end
end

puts area
