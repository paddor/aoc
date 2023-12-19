#! /bin/env -S ruby --jit

# frozen_string_literal: true


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


    def unfold
      @conditions      = ([@conditions] * 5).join('?')
      @damaged_groups *= 5
    end


    # rrutkow's python algo from https://github.com/rrutkows/aoc_py/blob/main/2023/d12.py ported to Ruby.
    # I don't understand it.
    #
    def arrangements(row = @conditions, pattern = @damaged_groups)
      permutations         = Hash.new 0
      permutations[[0, 0]] = 1

      row.each_char do |c|
        later = []
        permutations.each do |(group_id, group_amount), perm_count|
          if c != '#'
            if group_amount == 0
              later << [group_id, group_amount, perm_count]
            elsif group_amount == pattern[group_id]
              later << [group_id + 1, 0, perm_count]
            end
          end

          if c != '.'
            if group_id < pattern.size && group_amount < pattern[group_id]
              later << [group_id, group_amount + 1, perm_count]
            end
          end
        end

        permutations.clear

        later.each do |group_id, group_amount, perm_count|
          permutations[[group_id, group_amount]] += perm_count
        end
      end

      permutations.select { |k, v| valid?(*k) }.values.sum
    end


    def valid?(group_id, group_amount)
      group_id == @damaged_groups.size || (group_id == (@damaged_groups.size - 1) && group_amount == @damaged_groups[group_id])
    end

  end
end


if ARGV.first == '--test'
  correct = [1, 16384, 1, 16, 2500, 506250]
  p correct: correct
  result = HotSprings.parse(DATA.read).each(&:unfold).map { |record| record.arrangements }.tap { |arr| p arr }.zip(correct).map do |n, correct|
    p arrangements: n, correct: correct
    n
  end.sum
  puts "Sum: #{result}"
  puts "Test result: #{result == 525152 ? 'OK' : 'NOK'}"
else
  puts HotSprings.parse($<.read).each(&:unfold).map { |record| record.arrangements }.sum
end

__END__
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
