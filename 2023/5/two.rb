#! /bin/env -S ruby --jit

class Almanac
  def self.parse(input)
    seeds, *maps = input.split("\n\n")

    seed_ranges = seeds[/seeds: (.*)/, 1].split.map(&:to_i).each_slice(2).flat_map do |start, len|
      start .. start + len
    end

    maps.map! do |str|
      str.scan(/^(\d+) (\d+) (\d+)/).map do |matches|
        dst, src, len = matches.map(&:to_i)
        src_range     = src .. src + len
        dst_range     = dst .. dst + len

        [src_range, dst_range]
      end
    end

    Almanac.new seed_ranges, maps
  end


  def initialize(seed_ranges, maps)
    @seed_ranges = seed_ranges
    @maps        = maps
  end


  # Finds the lowest location that can be mapped to a seed in any of the seed ranges
  #
  def min_location
    (0..).find { |location| map_location_to_seed location }
  end


  def map_location_to_seed(location)
    potential_seed = @maps.reverse_each.inject(location) do |i, map|
      src_range, dst_range = map.find { |src_range, dst_range| dst_range.cover? i }

      if src_range
        diff = i - dst_range.begin
        src_range.begin + diff
      else
        i
      end
    end

    return potential_seed if @seed_ranges.any? { |range| range.cover? potential_seed }
  end


  # Uses much more RAM (400 MB) and is only slightly faster (175s vs 185s)
  #
  def map_location_to_seed2(location)
    @location_to_seed_map ||= Hash.new do |cache, location|
      potential_seed = @maps.reverse_each.inject(location) do |i, map|
        src_range, dst_range = map.find { |src_range, dst_range| dst_range.cover? i }

        if src_range
          diff = i - dst_range.begin
          src_range.begin + diff
        else
          i
        end
      end

      if @seed_ranges.any? { |range| range.cover? potential_seed }
        cache[location] = potential_seed
      else
        cache[location] = nil
      end
    end

    @location_to_seed_map[location]
  end
end


if ARGV.first == '--test'
  result = Almanac.parse(DATA.read).min_location
  puts result
  puts "Test result: #{result == 46 ? 'OK' : 'NOK'}"
else
  puts Almanac.parse($<.read).min_location
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
