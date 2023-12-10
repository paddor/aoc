#! /bin/env ruby


module AdventOfCode
  class Game
    def self.scan(input)
      input.each_line.map do |line|
        # puts
        # puts line

        id   = line[/Game (\d+)/, 1].to_i
        sets = line.split(';').map do |set|
          cubes_by_color = set.scan(/(\d+)\s+(red|green|blue)/).to_h do |n, color|
            [color.to_sym, n.to_i]
          end

          Set.new cubes_by_color
        end

        # p sets
        Game.new id, sets
      end
    end


    attr_reader :id


    def initialize(id, sets)
      @id   = id
      @sets = sets
    end


    def possible_with?(bag)
      @sets.all? do |set|
        set.all? do |color, n|
          bag[color] >= n
        end
      end
    end


    def minimum_set
      colors         = @sets.flat_map { |set| set.colors }.uniq
      cubes_by_color = colors.to_h do |color|
        [color, @sets.map { |set| set[color] }.max]
      end

      Set.new cubes_by_color
    end
  end


  class Set
    def initialize(cubes_by_color)
      @cubes_by_color = cubes_by_color
    end


    def power
      @cubes_by_color.values.inject { |product, n| product *= n }
    end


    def [](color)
      @cubes_by_color[color] || 0
    end


    def colors
      @cubes_by_color.keys
    end
  end
end


if ARGV.first == '--test'
  result = AdventOfCode::Game.scan(DATA).map { |game| game.minimum_set.power }.sum
  # puts "Sum: #{result}"
  puts "Test result: #{result == 2286 ? 'OK' : 'NOK'}"
else
  puts AdventOfCode::Game.scan($<).map { |game| game.minimum_set.power }.sum
end

__END__
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
