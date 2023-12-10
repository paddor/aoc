#! /bin/env ruby

def sum(input)
  input.each_line.map do |line|
    [line[/\d/], line.reverse[/\d/]].join.to_i
  end.sum
end


if ARGV.first == '--test'
  puts "Test result: #{sum(DATA) == 142 ? 'OK' : 'NOK'}"
else
  puts sum($<)
end

__END__
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
