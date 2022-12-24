require 'set'

input_set = Set.new
File.foreach('input.txt').with_index do |line, y|
  line.each_char.with_index do |c, x|
    input_set << [x, y] if c == '#'
  end
end

def print_set(set)
  min_x = set.min_by { _1[0] }[0]
  max_x = set.max_by { _1[0] }[0]
  min_y = set.min_by { _1[1] }[1]
  max_y = set.max_by { _1[1] }[1]
  (min_y..max_y).each do |y|
    (min_x..max_x).each do |x|
      print set.include?([x, y]) ? '#' : '.'
    end
    puts
  end
end

def vec_plus(a, b)
  [a.fetch(0) + b.fetch(0), a.fetch(1) + b.fetch(1)]
end

# round_number is 0 for the first round
def do_round(set, round_number)
  all_dirs = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]

  # Figure out the order that directions are proposed.
  pdirs = [[0, -1], [0, 1], [-1, 0], [1, 0]]
  (round_number % 4).times do
    pdirs << pdirs.shift
  end
  p pdirs

  # Calculate the proposals.
  proposals = {}
  set.each do |elf|
    proposal = nil
    lonely = all_dirs.none? { |dir| set.include?(vec_plus(elf, dir)) }
    pdirs.each do |dir|
      candidate = vec_plus(elf, dir)
      perps = dir[0] == 0 ? [[-1, 0], [1, 0]] : [[0, -1], [0, 1]]
      checks = [candidate, vec_plus(candidate, perps[0]), vec_plus(candidate, perps[1])]
      if checks.none? { |c| set.include?(c) }
        proposal = candidate
        break
      end
    end if !lonely
    proposal ||= elf
    (proposals[proposal] ||= []) << elf
  end

  # Calculate the new set.
  new_set = Set.new
  proposals.each do |proposal, elves|
    if elves.size == 1
      new_set.add(proposal)
    else
      new_set.merge(elves)
    end
  end
  new_set
end

def count_empty_ground(set)
  min_x = set.min_by { _1[0] }[0]
  max_x = set.max_by { _1[0] }[0]
  min_y = set.min_by { _1[1] }[1]
  max_y = set.max_by { _1[1] }[1]

  (max_x - min_x + 1) * (max_y - min_y + 1) - set.size
end

#print_set(input_set)
#print_set(do_round(input_set, 0))

set = input_set
10.times do |round_number|
  set = do_round(set, round_number)

  puts "End of round #{round_number + 1}"
  print_set(set)
  raise if set.size != input_set.size
  puts
end

puts count_empty_ground(set)

# too low: 3756
