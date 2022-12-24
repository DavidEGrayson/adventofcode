query_row = 2000000

sensors = {}
File.foreach('input.txt') do |line|
  md = line.match(/Sensor at x=(-?\d*), y=(-?\d*): closest beacon is at x=(-?\d*), y=(-?\d*)/)
  if md
    sensors[[md[1].to_i, md[2].to_i]] = [md[3].to_i, md[4].to_i]
  end
end
beacons = sensors.values

zones = []
sensors.each do |sensor_coords, beacon_coords|
  dist = (sensor_coords[0] - beacon_coords[0]).abs +
    (sensor_coords[1] - beacon_coords[1]).abs

  r = dist - (sensor_coords[1] - query_row).abs
  next if r < 0
  zone = ((sensor_coords[0] - r) .. (sensor_coords[0] + r))
  puts "#{sensor_coords}, #{beacon_coords} -> dist=#{dist}, r=#{r}, #{zone}"
  zones << zone
end

min_min = zones.map(&:min).min
max_max = zones.map(&:max).max

spots = 0
(min_min..max_max).each do |x|
  if beacons.include?([x, query_row])
    #print 'B'
  elsif zones.any? { |z| z.include?(x) }
    spots += 1
    #print '#'
  else
    #print '.'
  end
end
puts

p spots
