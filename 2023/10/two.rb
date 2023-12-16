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
    RIGHT => %w[- J 7]
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
    rows = input.each_line.map(&:chomp)
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


    ROW_SEGMENTS = /(?<ground>\.+)|(?<tangent>F-*7|L-*J)|(?<crossing>\||F-*J|L-*7)/


    def enclosed_tiles
      enclosed = 0

      # replace unconnected pipes with '.'
      rows = @rows.map.with_index do |row, y|
        row = row.dup
        row.chars.each.with_index { |c, x| row[x] = on_path?(x, y) ? c : '.' }
        row
      end

      # replace S with fitting pipe
      @start.then { |x, y| rows[y][x] = s_pipe }

      rows.each_with_index do |row, y|
        inside = false

        row.scan(ROW_SEGMENTS) do |ground, _tangent, crossing|
          if crossing
            inside = !inside
          elsif ground
            enclosed += ground.size if inside
          end
        end
      end

      enclosed
    end


    def on_path?(x, y)
      @path_cache ||= @path.to_h { |xy| [xy, nil] }

      @path_cache.has_key? [x, y]
    end


    def s_pipe
      a = @path[1]
      b = @path[-1]

      tiles = adjacent_tiles(@start)
      pos_a, _ = tiles.find { |_pos, xy| a == xy }
      pos_b, _ = tiles.find { |_pos, xy| b == xy }

      tile, _ = ALLOWED_STEPS.except('S').find do |tile, connectors|
        connectors.keys.include?(pos_a) && connectors.keys.include?(pos_b)
      end

      fail "can't find pipe that goes between #{a} and #{b}" unless tile

      tile
    end
  end
end


if ARGV.first == '--test'
  inputs = {
    <<~MAZE => 4,
      ...........
      .S-------7.
      .|F-----7|.
      .||.....||.
      .||.....||.
      .|L-7.F-J|.
      .|..|.|..|.
      .L--J.L--J.
      ...........
    MAZE
    <<~MAZE => 8,
      .F----7F7F7F7F-7....
      .|F--7||||||||FJ....
      .||.FJ||||||||L7....
      FJL7L7LJLJ||LJ.L-7..
      L--J.L7...LJS7F-7L7.
      ....F-J..F7FJ|L7L7L7
      ....L7.F7||L7|.L7L7|
      .....|FJLJ|FJ|F7|.LJ
      ....FJL-7.||.||||...
      ....L---J.LJ.LJLJ...
    MAZE
  }

  inputs.each do |input, should|
    puts '-' * 80
    puts input
    result = PipeMaze.parse(input).enclosed_tiles
    puts result
    is_correct = should == result
    puts "Test result: #{is_correct ? 'OK' : 'NOK'}"
    break unless is_correct
  end
else
  puts PipeMaze.parse($<.read).enclosed_tiles
end
