inputs = File.foreach('input.txt').map(&:chomp)

$adder = {
  '-==' => '-0', '-=-' => '-1', '-=0' => '-2', '-=1' => '0=', '-=2' => '0-',
  '--=' => '-1', '---' => '-2', '--0' => '0=', '--1' => '0-', '--2' => '00',
  '-0=' => '-2', '-0-' => '0=', '-00' => '0-', '-01' => '00', '-02' => '01',
  '-1=' => '0=', '-1-' => '0-', '-10' => '00', '-11' => '01', '-12' => '02',
  '-2=' => '0-', '-2-' => '00', '-20' => '01', '-21' => '02', '-22' => '1=',

  '0==' => '-1', '0=-' => '-2', '0=0' => '0=', '0=1' => '0-', '0=2' => '00',
  '0-=' => '-2', '0--' => '0=', '0-0' => '0-', '0-1' => '00', '0-2' => '01',
  '00=' => '0=', '00-' => '0-', '000' => '00', '001' => '01', '002' => '02',
  '01=' => '0-', '01-' => '00', '010' => '01', '011' => '02', '012' => '1=',
  '02=' => '00', '02-' => '01', '020' => '02', '021' => '1=', '022' => '1-',

  '1==' => '-2', '1=-' => '0=', '1=0' => '0-', '1=1' => '00', '1=2' => '01',
  '1-=' => '0=', '1--' => '0-', '1-0' => '00', '1-1' => '01', '1-2' => '02',
  '10=' => '0-', '10-' => '00', '100' => '01', '101' => '02', '102' => '1=',
  '11=' => '00', '11-' => '01', '110' => '02', '111' => '1=', '112' => '1-',
  '12=' => '01', '12-' => '02', '120' => '1=', '121' => '1-', '122' => '10',
}

def add_snafu(s1, s2)
  s1 = s1.split('')
  s2 = s2.split('')
  sum = ''
  carry = '0'
  while !s1.empty? || !s2.empty? || carry != '0'
    carry, value = $adder.fetch(carry + (s1.pop || '0') + (s2.pop || '0')).split('')
    sum << value
  end
  sum.reverse
end

sum = ''
inputs.each do |snafu|
  sum = add_snafu(sum, snafu)
end
puts sum
