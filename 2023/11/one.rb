#! /bin/env -S ruby --jit

class Universe
  def self.parse(input)
    new input.lines.map(&:chomp).map(&:chars)
  end


  def initialize(image)
    @image = image
    expand
  end


  private def expand
    @image = @image.map do |line|
      line.include?('#') ? [line] : [line] * 2
    end.flatten(1).transpose.map do |line|
      line.include?('#') ? [line] : [line] * 2
    end.flatten(1).transpose
  end


  def galaxies
    positions = []

    @image.each.with_index do |line, y|
      line.each.with_index do |char, x|
        positions << Complex.rect(x, y) if char == '#'
      end
    end

    positions
  end


  def galaxy_pairs
    galaxies.combination(2).map { |a, b| GalaxyPair.new @image, a, b }
  end


  class GalaxyPair
    def initialize(a, b)
      @a = a
      @b = b
    end


    def distance
      (@b - @a).rect.map(&:abs).sum
    end
  end
end


if ARGV.first == '--test'
  input = DATA.read
  puts input
  result = Universe.parse(input).galaxy_pairs.map(&:distance).sum
  puts result
  puts "Test result: #{result == 374 ? 'OK' : 'NOK'}"
else
  puts Universe.parse($<.read).galaxy_pairs.map(&:distance).sum
end

__END__
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
