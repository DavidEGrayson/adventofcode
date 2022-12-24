# Uses a doubly-linked list.

input = []
File.foreach('input.txt') do |line|
  input << line.to_i
end

$input_size = input.size

root = { value: input.shift }
root[:next] = root
root[:prev] = root

input.each do |value|
  node = { value: value }
  last = root[:prev]

  # Insert the node into the list.
  last[:next] = root[:prev] = node
  node[:next] = root
  node[:prev] = last

  # Preserve the original order of the input file
  last[:orig_next] = node
end

def find_node_by_value(start, value)
  node = start
  while true
    return node if node.fetch(:value) == value
    node = node.fetch(:next)
    return nil if node == start
  end
end

def travel(node, offset)
  raise if offset < 0
  while offset > 0
    node = node.fetch(:next)
    offset -= 1
  end
  node
end

def mix_once(root)
  current = root
  while current
    # The modulo here is critical for part 2, and also makes it so we
    # don't have to handle negative values specially.
    value = current.fetch(:value) % ($input_size - 1)

    if value > 0
      # Remove 'current' from its current position.
      current[:prev][:next] = current.fetch(:next)
      current[:next][:prev] = current.fetch(:prev)

      # Figure out where this node needs to move to.
      dest_prev = travel(current, value)
      dest_next = dest_prev.fetch(:next)

      # Insert 'current' between dest_prev and dest_next
      dest_prev[:next] = dest_next[:prev] = current
      current[:next] = dest_next
      current[:prev] = dest_prev
    end

    current = current[:orig_next]
  end
end

# Part 1
# mix_once(root)

# Part 2
current = root
while current
  current[:value] *= 811589153
  current = current[:orig_next]
end
10.times { mix_once(root) }

zero = find_node_by_value(root, 0)
values = [1000, 2000, 3000].map { |i| travel(zero, i).fetch(:value) }
puts values.sum
