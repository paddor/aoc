#! /bin/env ruby

DIGITS = {
  'one'   => '1',
  'two'   => '2',
  'three' => '3',
  'four'  => '4',
  'five'  => '5',
  'six'   => '6',
  'seven' => '7',
  'eight' => '8',
  'nine'  => '9',
}

REGEX_FIRST = /[0-9]|#{DIGITS.keys.join('|')}/
REGEX_LAST  = /[0-9]|#{DIGITS.keys.map(&:reverse).join('|')}/


def sum(input)
  input.each_line.map do |line|
    # puts
    # puts line

    # NOTE: does not work because of cases like --test2 below
    # result = line.scan(/[0-9]|one|two|three|four|five|six|seven|eight|nine/)
    # p result
    # first, *rest, last = result

    first = line[REGEX_FIRST]
    last  = line.reverse[REGEX_LAST].reverse

    # p first: first, last: last
    num = [DIGITS[first] || first, DIGITS[last] || last].join.to_i
    # p num: num
    num
  end.sum
end


case ARGV.first
when '--test'
  sum = sum(DATA)
  puts "Sum: #{sum}"
  puts "Test result: #{sum == 281 ? 'OK' : 'NOK'}"
when '--test2'
  sum = sum('mhnmzzseven1hrmxlbjpzjfjfsrdbqplgzrnsix9oneightpl')
  puts "Test result: #{sum == 78 ? 'OK' : 'NOK'}"
else
  puts sum($<)
end

__END__
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
