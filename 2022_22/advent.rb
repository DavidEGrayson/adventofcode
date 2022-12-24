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
$map = map

def transform(in_a, in_b, out_a, out_b, input)
  mult = (out_b - out_a) / (in_b - in_a)
  raise if ![-1, 1].include?(mult)
  out_a + (input - in_a) * mult
end

def move1(x, y, face, sanity=false)
  new_x = x
  new_y = y
  new_face = face

  while true
    tmp_x, tmp_y, tmp_face = new_x, new_y, new_face

    dx = [1, 0, -1, 0].fetch(new_face)
    dy = [0, 1, 0, -1].fetch(new_face)
    new_y += dy
    new_x += dx

    if $map[new_y][new_x] == ' '
      if new_x == 151 && (1..50).include?(new_y)       # B to D
        new_x, new_y = 100, transform(1, 50, 150, 101, new_y)
        new_face = 2

      elsif new_x == 101 && (101..150).include?(new_y) # D to B
        new_x, new_y = 150, transform(150, 101, 1, 50, new_y)
        new_face = 2

      elsif (51..100).include?(new_x) && new_y == 0    # A to F
        new_x, new_y = 1, transform(51, 100, 151, 200, new_x)
        new_face = 0

      elsif new_x == 0 && (151..200).include?(new_y)   # F to A
        new_x, new_y = transform(151, 200, 51, 100, new_y), 1
        new_face = 1

      elsif (1..50).include?(new_x) && new_y == 201    # F to B
        new_x, new_y = new_x + 100, 1
        new_face = 1  # redundant

      elsif (101..150).include?(new_x) && new_y == 0   # B to F
        new_x, new_y = new_x - 100, 200
        new_face = 3  # redundant

      elsif new_x == 51 && (151..200).include?(new_y)  # F to D
        new_x, new_y = transform(151, 200, 51, 100, new_y), 150
        new_face = 3

      elsif (51..100).include?(new_x) && new_y == 151  # D to F
        new_x, new_y = 50, transform(51, 100, 151, 200, new_x)
        new_face = 2

      elsif new_x == 50 && (1..50).include?(new_y)     # A to E
        new_x, new_y = 1, transform(1, 50, 150, 101, new_y)
        new_face = 0

      elsif new_x == 0 && (101..150).include?(new_y)   # E to A
        new_x, new_y = 51, transform(150, 101, 1, 50, new_y)
        new_face = 0

      elsif (1..50).include?(new_x) && new_y == 100    # E to C
        new_x, new_y = 51, transform(1, 50, 51, 100, new_x)
        new_face = 0

      elsif new_x == 50 && (51..100).include?(new_y)   # C to E
        new_x, new_y = transform(51, 100, 1, 50, new_y), 101
        new_face = 1

      elsif new_x == 101 && (51..100).include?(new_y)  # C to B
        new_x, new_y = transform(51, 100, 101, 150, new_y), 50
        new_face = 3

      elsif (101..150).include?(new_x) && new_y == 51  # B to C
        new_x, new_y = 100, transform(101, 150, 51, 100, new_x)
        new_face = 2

      else
        $stderr.puts "Unknown space: #{new_x},#{new_y}, #{new_face}"
        exit 2
      end

      # Sanity check: if we moved backwards do we get to where we were before?
      if !sanity
        s_x, s_y, s_face = move1(new_x, new_y, ((new_face + 2) % 4), true)
        if s_x != tmp_x || s_y != tmp_y || s_face != ((tmp_face + 2) % 4)
          $stderr.puts "Sanity check failed."
          $stderr.puts "tmp:  #{tmp_x},#{tmp_y}, #{tmp_face}"
          $stderr.puts "new:  #{new_x},#{new_y}, #{new_face}"
          $stderr.puts "sane: #{s_x},#{s_y}, #{s_face}"
          exit 3
        end
      end
    end
    if $map[new_y][new_x] == ' '
      $stderr.puts "Still in a space: #{new_x},#{new_y}, #{new_face}"
      exit 3
    end
    break
  end

  [new_x, new_y, new_face]
end

y = 1
x = map[y].index('.')
face = 0   # 0 = right, 1 = down, etc.

instructions.each do |inst|
  case inst
  when :L
    face = (face - 1) % 4
  when :R
    face = (face + 1) % 4
  when Integer
    inst.times do
      new_x, new_y, new_face = move1(x, y, face)
      if map[new_y][new_x] == '.'
        x = new_x
        y = new_y
        face = new_face
      elsif map[new_y][new_x] == '#'
        break  # Blocked by a wall.
      end
    end
  end
end
map[y][x] = '*'

puts 1000 * y + 4 * x + face
