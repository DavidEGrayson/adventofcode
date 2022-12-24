map = ['']
instructions = []
File.foreach('input.txt') do |line|
  md = line.match(/\d/)
  if md
    line.scan(/(\d+|R|L)/) do |m|
      if 'LR'.include?(m[0])
        instructions << m[0].to_sym
      else
        instructions << m[0].to_i
      end
    end
  else
    map << ' ' + line.chomp + ' '
  end
end
map << ''
width = map.map(&:size).max
map = map.map { |line| line.ljust(width) }

y = 1
x = map[y].index('.')
face = 0   # 0 = right, 1 = down, etc.

instructions.each do |inst|
  puts "Executing #{inst}"
  case inst
  when :L
    face = (face - 1) % 4
  when :R
    face = (face + 1) % 4
  when Integer
    dx = [1, 0, -1, 0].fetch(face)
    dy = [0, 1, 0, -1].fetch(face)
    inst.times do
      new_y = y
      new_x = x
      while true
        new_y = (new_y + dy) % map.size
        new_x = (new_x + dx) % map[new_y].size
        #puts "Trying to move to #{new_x}, #{new_y}"
        next if map[new_y][new_x] == ' '
        break
      end
      if map[new_y][new_x] == '.'
        x = new_x
        y = new_y
      elsif map[new_x][new_x] == '#'
        break
      end
      #map[y][x] = face.to_s
      #puts "Moved to #{x},#{y}"
    end
  end
end
map[y][x] = '*'

puts map

puts 1000 * y + 4 * x + face

# WRONG: 149230
