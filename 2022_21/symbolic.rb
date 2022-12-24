input = {}
File.foreach('input.txt') do |line|
  if md = line.match(/(\w+): (\d+)/)
    input[md[1].to_sym] = md[2].to_i
  elsif md = line.match(/(\w+): (\w+) (.) (\w+)/)
    input[md[1].to_sym] = [md[3].to_sym, md[2].to_sym, md[4].to_sym]
  else
    $stderr.puts "Unrecognized line: #{line}"
    exit 1
  end
end
input[:humn] = :humn

# Evaluates to an expression of the form (A*humn + B)/C, encoded as [a, b, c]
# Division might cause problems.
def eval_to_humn(input, name)
  value = input.fetch(name)
  case value
  when Integer then [0, value, 1]
  when :humn then [1, 0, 1]
  when Array then
    op = value[0]
    left = eval_to_humn(input, value[1]) or raise "#{value[1]} is nil"
    right = eval_to_humn(input, value[2]) or raise "#{value[2]} is nil"

    # Some common code for addition and subtraction
    c = left[2] * right[2]  # should be LCM if we want smaller numbers
    left_a = left[0] * c / left[2]
    left_b = left[1] * c / left[2]
    right_a = right[0] * c / right[2]
    right_b = right[1] * c / right[2]

    case op
    when :+
      [left_a + right_a, left_b + right_b, c]
    when :-
      [left_a - right_a, left_b - right_b, c]
    when :*
      if left[0] == 0
        [right[0] * left[1], right[1] * left[1], right[2] * left[2]]
      elsif right[0] == 0
        [left[0] * right[1], left[1] * right[1], left[2] * right[2]]
      else
        $stderr.puts "Quadratic humn value encountered for #{name}"
        exit
      end
    when :/
      if right[0] == 0 && right[2] == 1
        [left[0], left[1], left[2] * right[1]]
      else
        $stderr.puts "Unhandleded division case for #{name}: #{left.inspect} / #{right.inspect}"
        exit
      end
    end
  else
    raise "Unknown type of value for #{name}: #{value}"
  end
end

input[:root][0] = :-
rh = eval_to_humn(input, :root)
puts rh[2]
puts "(#{rh[0]}) * humn + (#{rh[1]}) == 0"

puts "humn: " + (-rh[1]/rh[0]).to_s
