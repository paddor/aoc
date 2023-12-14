#! /bin/env ruby

class Race
  def self.parse_document(input)
    times     = input[/^Time:\s*(.+)/, 1].split.map(&:to_i)
    distances = input[/^Distance:\s*(.+)/, 1].split.map(&:to_i)

    times.zip(distances).map do |time, distance|
      Race.new time, distance
    end
  end


  def initialize(time, distance)
    @time     = time
    @distance = distance
  end


  def winning_strategies
    (1...@time).select do |hold_time|
      speed          = hold_time
      remaining_time = @time - hold_time
      distance       = speed * remaining_time

      distance > @distance
    end
  end
end


if ARGV.first == '--test'
  result = Race.parse_document(DATA.read).map { |race| race.winning_strategies.count }.inject(:*)
  puts result
  puts "Test result: #{result == 288 ? 'OK' : 'NOK'}"
else
  puts Race.parse_document($<.read).map { |race| race.winning_strategies.count }.inject(:*)
end

__END__
Time:      7  15   30
Distance:  9  40  200
