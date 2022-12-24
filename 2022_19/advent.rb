Resources = %i(ore clay obsidian geode)

$blueprints = {}
File.foreach('input.txt') do |line|
  md = line.match(/Blueprint (\d+):/)
  if !md
    $stderr.puts "Unrecognized line: #{line}"
    exit 1
  end
  blueprint_id = md[1].to_i
  blueprint = {}
  line.scan(/Each (\w+) robot costs ([^.]+)./) do |robot_type, cost_str|
    cost = {}
    cost_str.scan(/(\d+) (\w+)/) do |amount, resource|
      cost[resource.to_sym] = amount.to_i
    end
    blueprint[robot_type.to_sym] = cost
  end
  $blueprints[blueprint_id] = blueprint
end

# For ore, clay, and obsidian, don't invest into robots that will bring in
# more resources per turn than we can possibly spend.
$blueprints.each_value do |bp|
  robot_limit = { ore: 0, clay: 0, obsidian: 0 }
  bp.each_value do |cost|
    cost.each do |resource, amount|
      robot_limit[resource] = amount if robot_limit[resource] < amount
    end
  end
  bp[:robot_limit] = robot_limit
end

def print_blueprint(bp)
  puts "Blueprint:"
  bp.each do |robot_type, cost|
    print "  #{robot_type}: "
    cost.each do |resource, amount|
      print "#{amount} #{resource}, "
    end
    puts
  end
  puts
end

def res_greater_than_or_equal(a, b)
  Resources.all? { |r| a.fetch(r, 0) >= b.fetch(r, 0) }
end

def res_plus(a, b)
  sum = {}
  Resources.each do |r|
    sum[r] = a.fetch(r, 0) + b.fetch(r, 0)
  end
  sum
end

def res_minus(a, b)
  sum = {}
  Resources.each do |r|
    sum[r] = a.fetch(r, 0) - b.fetch(r, 0)
  end
  sum
end

def max_geodes(bp, time_left, robots, resources, desired_robot)
  if time_left == 0
    geodes = resources.fetch(:geode)
    if geodes > bp.fetch(:max_geodes, 0)
      bp[:max_geodes] = geodes
    end
    return geodes
  end

  if !desired_robot
    # Pick which robot we are aiming to build next.
    options = Resources.select do |r|
      robots.fetch(r) < bp[:robot_limit].fetch(r, 99999999999)
    end

    return options.map do |dr|
      max_geodes(bp, time_left, robots, resources, dr)
    end.max
  end

  if false
    puts "----"
    puts "time_left: #{time_left}"
    puts "robots: #{robots.inspect}"
    puts "res: #{resources.inspect}"
    puts "desired_robot: #{desired_robot}"
  end

  # Start building robot.
  building = nil
  if res_greater_than_or_equal(resources, bp.fetch(desired_robot))
    building = desired_robot
    resources = res_minus(resources, bp.fetch(building))
  end

  # Collect resources.
  resources = res_plus(resources, robots)

  # Finish building robot.
  if building
    robots = robots.dup
    robots[building] += 1
    desired_robot = nil
  end

  max_geodes(bp, time_left - 1, robots, resources, desired_robot)
end

def max_geodes_for_bp(bp, time_left)
  return bp[:max_geodes] if bp[:max_geodes]
  robots = { ore: 1, clay: 0, obsidian: 0, geode: 0 }
  resources = { ore: 0, clay: 0, obsidian: 0, geode: 0 }
  max_geodes(bp, time_left, robots, resources, nil)
  bp.fetch(:max_geodes)
end

# Part 1
# sum = 0
# $blueprints.each_key do |id|
#   mg = max_geodes_for_bp($blueprints[id], 24)
#   sum += mg * id
# end
# puts sum

# Part 2
prod = 1
$blueprints.values_at(1, 2, 3).each do |bp|
  mg = max_geodes_for_bp(bp, 32)
  prod *= mg
  puts "mg: #{mg}"
end
puts prod

