#! /bin/env ruby

class Almanac
  def self.parse(input)
    seeds, *maps = input.split("\n\n")
    seeds = seeds[/seeds: (.*)/, 1].split.map(&:to_i)

    maps.map! do |str|
      str.scan(/^(\d+) (\d+) (\d+)/).map do |matches|
        dst, src, len = matches.map(&:to_i)
        diff          = src - dst
        range         = src .. src + len
        [range, diff]
      end
    end

    Almanac.new seeds, maps
  end


  def initialize(seeds, maps)
    @seeds = seeds
    @maps  = maps
  end


  def locations
    @seeds.map do |seed|
      @maps.inject(seed) do |i, map|
        _, diff = map.find { |range, diff| range.cover? i }
        diff ? i - diff : i
      end
    end
  end
end


if ARGV.first == '--test'
  result = Almanac.parse(DATA.read).locations.min
  puts result
  puts "Test result: #{result == 35 ? 'OK' : 'NOK'}"
else
  puts Almanac.parse($<.read).locations.min
end

__END__
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
