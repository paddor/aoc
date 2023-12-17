#! /bin/env -S ruby --jit

class HotSprings
  def self.parse(input)
    input.lines.map do |line|
      conditions, damaged_groups = line.split
      damaged_groups = damaged_groups.split(',').map(&:to_i)

      Record.new conditions, damaged_groups
    end
  end


  class Record
    def initialize(conditions, damaged_groups)
      @conditions     = conditions
      @damaged_groups = damaged_groups
    end


    def arrangements
      diff              = @damaged_groups.sum - @conditions.count('#')
      unknown_positions = []

      @conditions.scan(/\?/) do
        unknown_positions << $~.offset(0)[0]
      end

      combos = unknown_positions.combination(diff).select do |combo|
        candidate = @conditions.dup
        combo.each { |i| candidate[i] = '#' }
        groups = candidate.scan(/#+/).map(&:size)
        groups == @damaged_groups
      end

      combos.size
    end
  end
end


if ARGV.first == '--test'
  correct = [1, 4, 1, 1, 4, 10]
  p correct
  result = HotSprings.parse(DATA.read).map { |record| record.arrangements }.sum
  puts result
  puts "Test result: #{result == 21 ? 'OK' : 'NOK'}"
else
  puts HotSprings.parse($<.read).map { |record| record.arrangements }.sum
end

__END__
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
