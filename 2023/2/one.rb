#! /bin/env ruby

BAG = {
  'red'   => 12,
  'green' => 13,
  'blue'  => 14,
}


class Game
  def self.filter(input, bag)
    scan(input).select { |game| game.possible_with? bag }
  end


  def self.scan(input)
    input.each_line.map do |line|
      # puts
      # puts line

      id   = line[/Game (\d+)/, 1].to_i
      sets = line.split(';').map do |set|
        set.scan(/(\d+)\s+(red|green|blue)/).to_h do |n, color|
          [color, n.to_i]
        end
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
end


if ARGV.first == '--test'
  result = Game.filter(DATA, BAG).map(&:id).sum
  puts "Test result: #{result == 8 ? 'OK' : 'NOK'}"
else
  puts Game.filter($<, BAG).map(&:id).sum
end

__END__
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
