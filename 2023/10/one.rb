#! /bin/env -S ruby --jit

module PipeMaze
  UP    = :up
  DOWN  = :down
  LEFT  = :left
  RIGHT = :right


  CONNECTORS = {
    UP    => %w[| 7 F],
    DOWN  => %w[| L J],
    LEFT  => %w[- L F],
    RIGHT => %w[- J 7],
  }


  ALLOWED_STEPS = {
    'S' => CONNECTORS,
    '|' => CONNECTORS.slice(UP, DOWN),
    '-' => CONNECTORS.slice(LEFT, RIGHT),
    'L' => CONNECTORS.slice(UP, RIGHT),
    'J' => CONNECTORS.slice(UP, LEFT),
    '7' => CONNECTORS.slice(DOWN, LEFT),
    'F' => CONNECTORS.slice(DOWN, RIGHT),
    '.' => {},
  }


  INVERTED_DIRECTIONS = {
    UP    => DOWN,
    DOWN  => UP,
    LEFT  => RIGHT,
    RIGHT => LEFT,
  }


  def self.parse(input)
    rows = input.each_line.map(&:chomp).map(&:chars)
    y    = rows.find_index { |line| line.include? 'S' }
    x    = rows[y].index 'S'

    Loop.new rows, [x, y]
  end


  class Loop
    def initialize(rows, start)
      @rows  = rows
      @start = start
      @path  = find_path
    end


    private def find_path
      path = [@start]

      loop do
        cur, prev  = path[-1], path[-2]
        directions = ALLOWED_STEPS[tile *cur].keys
        tiles      = adjacent_tiles(cur).slice(*directions)

        _, xy = tiles.find do |dir, xy|
          next if prev == xy
          ALLOWED_STEPS[tile *xy].has_key? INVERTED_DIRECTIONS.fetch(dir)
        end

        break if xy == @start

        path << xy
      end

      path
    end


    def tile(x, y)
      @rows[y][x]
    end


    private def adjacent_tiles(xy)
      x, y = xy

      {
        UP    => [x,     y - 1],
        LEFT  => [x - 1, y    ],
        RIGHT => [x + 1, y    ],
        DOWN  => [x,     y + 1],
      }.reject { |_, xy| xy.any?(&:negative?) }
    end


    def max_steps
      (@path.size.to_f / 2).ceil
    end
  end
end


if ARGV.first == '--test'
  result = PipeMaze.parse(DATA.read).max_steps
  puts result
  puts "Test result: #{result == 8 ? 'OK' : 'NOK'}"
else
  puts PipeMaze.parse($<.read).max_steps
end

__END__
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
