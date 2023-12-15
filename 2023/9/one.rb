#! /bin/env -S ruby --jit

class Oasis
  class History
    def self.parse(input)
      input.each_line.map do |line|
        History.new line.split.map(&:to_i)
      end
    end


    attr_reader :values


    def initialize(values)
      @values = values
    end


    def extrapolate(n = 1)
      n.times do
        diffs  = [@values]

        until diffs.last.all?(&:zero?)
          diffs << differences(diffs.last)
        end

        diffs.reverse.each_cons 2 do |bottom, top|
          top << top.last + bottom.last
        end
      end

      self
    end


    def differences(values)
      values.each_cons(2).map { |a, b| b - a }
    end
  end
end


if ARGV.first == '--test'
  result = Oasis::History.parse(DATA.read).map { |hist| hist.extrapolate.values.last }.sum
  puts result
  puts "Test result: #{result == 114 ? 'OK' : 'NOK'}"
else
  puts Oasis::History.parse($<.read).map { |hist| hist.extrapolate.values.last }.sum
end

__END__
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
