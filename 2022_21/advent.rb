$input = {}
File.foreach('input.txt') do |line|
  if md = line.match(/(\w+): (\d+)/)
    $input[md[1].to_sym] = md[2].to_i
  elsif md = line.match(/(\w+): (\w+) (.) (\w+)/)
    $input[md[1].to_sym] = [md[3].to_sym, md[2].to_sym, md[4].to_sym]
  else
    $stderr.puts "Unrecognized line: #{line}"
    exit 1
  end
end

def eval_to_int(name)
  value = $input.fetch(name)
  case value
  when Integer then value
  when Array then
    op = value[0]
    left = eval_to_int(value[1])
    right = eval_to_int(value[2])
    left.send(op, right)
  else
    raise "Unknown type of value for #{name}: #{value}"
  end
end

# Evaluates the left-hand side of the inequality minus the right-hand side.
# Want this to return 0.
def try_humn(humn_value)
  $input[:humn] = humn_value
  $input[:root][0] = :-
  eval_to_int(:root)
end

# try_humn(0) is a large positive number.
# try_humn(1 << 64) is a large negative nubmer.
# Given the observations above, let's do a bit-based binary search to find the
# largest humn value where try_humn is positive, then just add 1 to it, to get
# the lowest value where where try_humn is 0.
guess = 0
63.downto(0) do |i|
  mask = 1 << i
  guess |= mask if try_humn(guess | mask) > 0
end
puts guess + 1
