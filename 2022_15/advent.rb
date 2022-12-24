query_row = 2000000

$sensors = {}
File.foreach('input.txt') do |line|
  md = line.match(/Sensor at x=(-?\d*), y=(-?\d*): closest beacon is at x=(-?\d*), y=(-?\d*)/)
  if md
    $sensors[[md[1].to_i, md[2].to_i]] = [md[3].to_i, md[4].to_i]
  end
end
beacons = $sensors.values

def check_row(query_row)
  zones = []
  $sensors.each do |sensor_coords, beacon_coords|
    dist = (sensor_coords[0] - beacon_coords[0]).abs +
      (sensor_coords[1] - beacon_coords[1]).abs

    r = dist - (sensor_coords[1] - query_row).abs
    next if r < 0
    zone = ((sensor_coords[0] - r) .. (sensor_coords[0] + r))
    #puts "#{sensor_coords}, #{beacon_coords} -> dist=#{dist}, r=#{r}, #{zone}"
    zones << zone
  end

  x = 0  # tmphax num
  while x <= 4000000   # tmphax num
    inside_zones = zones.select { |z| z.include?(x) }
    if inside_zones.empty?
      p [x, query_row]
      puts x * 4000000 + query_row
      x += 1  # eeek
    else
      x = inside_zones.map(&:max).max + 1
    end
  end
end

(0..4000000).each do |y|
  #puts y if (y % 1000) == 0
  check_row(y)
end
