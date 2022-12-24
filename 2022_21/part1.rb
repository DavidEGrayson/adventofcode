b = binding
while true
  had_error = false
  File.foreach('input.txt') do |line|
    line.gsub!(':', '=')
    #puts line
    begin
      eval(line, b)
    rescue NameError, TypeError => e
      #puts e
      had_error = true
    end
  end
  break if !had_error
end
puts b.eval('root')

