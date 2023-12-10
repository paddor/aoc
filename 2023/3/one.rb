#! /bin/env ruby

module AdventOfCode
  def self.part_numbers(input)
    part_numbers = []
    lines        = input.read.lines

    lines.each.with_index do |line, line_number|
      previous_line = lines[line_number - 1]
      next_line     = lines[line_number + 1]

      # puts
      # puts previous_line if previous_line
      # puts line
      # puts next_line if next_line

      line.scan(/\d+/) do |num|
        # p num: num
        char_before = Regexp.last_match.pre_match[-1]
        char_after  = Regexp.last_match.post_match.chomp[0]

        if char_before && char_before != '.'
          # p found: num, char_before: char_before
          part_numbers << num
          next

        elsif char_after && char_after != '.'
          # p found: num, char_after: char_after
          part_numbers << num
          next
        else
          offset = Regexp.last_match.offset(0)[0]

          if previous_line
            range         = [0, offset - 1].max..(offset + num.size)
            relevant_part = previous_line[range].chomp

            if relevant_part =~ /[^0-9.]/
              # p found: num, in_previous_line: relevant_part
              part_numbers << num
              next
            end
          end

          if next_line
            range         = [0, offset - 1].max .. (offset + num.size)
            relevant_part = next_line[range].chomp

            if relevant_part =~ /[^0-9.]/
              # p found: num, in_next_line: relevant_part
              part_numbers << num
              next
            end
          end
        end

        # p skipped: num
      end
    end

    part_numbers.map(&:to_i)
  end
end


if ARGV.first == '--test'
  result = AdventOfCode.part_numbers(DATA).sum
  puts "Sum: #{result}"
  puts "Test result: #{result == 4361 ? 'OK' : 'NOK'}"
else
  puts AdventOfCode.part_numbers($<).sum
end

__END__
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
