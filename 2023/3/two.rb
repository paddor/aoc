#! /bin/env ruby

module AdventOfCode
  class Schematic
    def initialize(input)
      @lines = tokenize input
    end


    private def tokenize(input)
      input.lines.map(&:chomp).map do |line|
        tokens = []

        line.scan(/(?<number>\d+)|(?<gear>\*)|(?<symbol>[^.])/) do |match|
          match_data = Regexp.last_match
          offset     = match_data.offset(0)[0]
          len        = match_data[0].size
          range      = offset .. offset + len - 1

          if match_data['number']
            tokens << Token::Number.new(range, match_data[0])
          elsif match_data['gear']
            tokens << Token::Gear.new(range, match_data[0])
          elsif match_data['symbol']
            tokens << Token::Symbol.new(range, match_data[0])
          end
        end

        tokens
      end
    end


    def gears
      gears = []

      @lines.each.with_index do |tokens, i|
        tokens.grep(Token::Gear).each do |gear|
          adjacent_numbers = adjacent_numbers(i, gear.offset)

          if adjacent_numbers.size == 2
            a, b = adjacent_numbers.map(&:number)
            gears << Gear.new(a, b)
          end
        end
      end

      gears
    end


    private def adjacent_numbers(i, j)
      positions = [
        [i-1, j-1], [i-1, j], [i-1, j+1],
        [i,   j-1], [i,   j], [i,   j+1],
        [i+1, j-1], [i+1, j], [i+1, j+1],
      ]

      positions.map do |y, x|
        @lines[y].grep(Token::Number).find { |num| num.cover? x }
      end.compact.uniq
    end
  end


  class Gear
    def initialize(num_a, num_b)
      @a, @b = num_a, num_b
    end


    def ratio
      @a * @b
    end
  end


  class Token
    def initialize(range, string)
      @range  = range
      @string = string
    end


    def offset
      @range.begin
    end


    def cover?(offset)
      @range.cover? offset
    end


    class Number < Token
      def number
        @string.to_i
      end
    end


    class Gear < Token
    end


    class Symbol < Token
    end
  end
end


if ARGV.first == '--test'
  result = AdventOfCode::Schematic.new(DATA.read).gears.map(&:ratio).sum
  puts "Sum: #{result}"
  puts "Test result: #{result == 467835 ? 'OK' : 'NOK'}"
else
  puts AdventOfCode::Schematic.new($<.read).gears.map(&:ratio).sum
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
