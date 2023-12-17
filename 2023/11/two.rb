#! /bin/env -S ruby --jit -rpp

class Universe
  def self.parse(input)
    new input.lines.map(&:chomp).map(&:chars)
  end


  attr_accessor :expansion


  def initialize(image)
    @image             = image
    @expansion         = 1
    @x_rates, @y_rates = analyze_rates
  end


  private def analyze_rates
    x_rates = [0]
    y_rates = [0]

    @image.each do |row|
      rate  = y_rates.last
      rate += 1 unless row.include? '#'

      y_rates << rate
    end

    @image.transpose.each do |column|
      rate  = x_rates.last
      rate += 1 unless column.include? '#'

      x_rates << rate
    end

    [x_rates, y_rates]
  end


  def galaxies
    positions = []

    @image.each.with_index do |line, y|
      line.each.with_index do |char, x|
        positions << Complex.rect(x, y) if char == '#'
      end
    end

    positions.map { |position| expand position }
  end


  def expand(position)
    x, y    = position.rect
    x_rate  = @x_rates[x]
    y_rate  = @y_rates[y]
    x      += @expansion * x_rate - x_rate
    y      += @expansion * y_rate - y_rate

    Complex.rect(x, y)
  end


  def galaxy_pairs
    galaxies.combination(2).map { |a, b| GalaxyPair.new a, b }
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

  {
    10  => 1030,
    100 => 8410,
  }.each do |n, correct_sum|
    uni = Universe.parse(input)
    uni.expansion = n
    result = uni.galaxy_pairs.map(&:distance).sum
    puts result
    puts "Correct: #{correct_sum}"
    puts "Test result: #{result == correct_sum ? 'OK' : 'NOK'}"
  end
else
  uni = Universe.parse($<.read)
  uni.expansion = 1_000_000
  puts uni.galaxy_pairs.map(&:distance).sum
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
