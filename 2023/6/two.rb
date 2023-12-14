#! /bin/env ruby

class Race
  def self.parse_document(input)
    time     = input[/^Time:\s*(.+)/, 1].split.join.to_i
    distance = input[/^Distance:\s*(.+)/, 1].split.join.to_i

    Race.new time, distance
  end


  def initialize(time, distance)
    @time     = time
    @distance = distance
  end


  def winning_strategies
    # brute force
    # return (1...@time).select do |hold_time|
    #   speed          = hold_time
    #   remaining_time = @time - hold_time
    #   distance       = speed * remaining_time
    #   distance > @distance
    # end

    # idea: stop filtering after longest winning hold time
    # return (1...@time).drop_while do |hold_time|
    #   speed          = hold_time
    #   remaining_time = @time - hold_time
    #   distance       = speed * remaining_time
    #   distance <= @distance
    # end.take_while do |hold_time|
    #   speed          = hold_time
    #   remaining_time = @time - hold_time
    #   distance       = speed * remaining_time
    #   distance > @distance
    # end

    # idea: find random hold_time that wins and extrapolate
    time_range = 1...@time
    ok_time    = nil
    loop do
      ok_time        = rand time_range
      speed          = ok_time
      remaining_time = @time - ok_time
      distance       = speed * remaining_time
      break if distance > @distance
    end

    # find min/max hold times that win using binary search
    shortest = (1..ok_time).bsearch do |hold_time|
      speed          = hold_time
      remaining_time = @time - hold_time
      distance       = speed * remaining_time
      distance > @distance
    end

    longest = (ok_time...@time).bsearch do |hold_time|
      speed          = hold_time
      remaining_time = @time - hold_time
      distance       = speed * remaining_time
      distance <= @distance # bsearch needs all false-evaluating elements to precede all true-evaluating elements
    end - 1

    shortest..longest
  end
end


if ARGV.first == '--test'
  result = Race.parse_document(DATA.read).winning_strategies.count
  puts result
  puts "Test result: #{result == 71503 ? 'OK' : 'NOK'}"
else
  puts Race.parse_document($<.read).winning_strategies.count
end

__END__
Time:      7  15   30
Distance:  9  40  200
