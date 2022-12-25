inputs = File.foreach('input.txt').map(&:chomp)

$sd = { '=' => -2, '-' => -1, '0' => 0, '1' => 1, '2' => 2, nil => 0 }
$ds = { -2 => '=', -1 => '-', 0 => '0', 1 => '1', 2 => '2' }

def add_snafu(s1, s2)
  sum = ''
  i = 0
  carry = 0
  s1 = s1.reverse
  s2 = s2.reverse
  while i < s1.size || i < s2.size || carry != 0
    value = carry + $sd.fetch(s1[i]) + $sd.fetch(s2[i])
    carry = 0
    if value < -2
      value += 5
      carry = -1
    end
    if value > 2
      value -= 5
      carry = 1
    end
    sum << $ds.fetch(value)
    i += 1
  end
  sum.reverse
end

sum = ''
inputs.each do |snafu|
  sum = add_snafu(sum, snafu)
end
puts sum
