#! /bin/env -S ruby --jit -rpp

# dcclct13's python solution from https://www.reddit.com/r/adventofcode/comments/18h940b/2023_day_13_solutions/
# patterns = [p.splitlines() for p in getinput(13).split("\n\n")]
# diff = lambda p, j: sum(sum(a != b for a, b in zip(l[j:], l[j - 1 :: -1])) for l in p)
# mirror = lambda p, d: sum(j for j in range(1, len(p[0])) if diff(p, j) == d)
# summarize = lambda p, d: mirror(p, d) + 100 * mirror([*zip(*p)], d)
# print(sum(summarize(p, 0) for p in patterns))
# print(sum(summarize(p, 1) for p in patterns))


# adapted to Ruby:
patterns  = $<.read.split("\n\n").map { |para| para.lines.map(&:chomp).map(&:chars) }
diff      = ->(p, j) { p.map { |l| l[j..-1].zip(l[0...j].reverse).count { _1 && _2 && _1 != _2 } }.sum }
mirror    = ->(p, d) { (1...p[0].size).select { |j| diff[p, j] == d }.sum }
summarize = ->(p, d) { mirror[p, d] + 100 * mirror[p.transpose, d] }
puts patterns.map { |p| summarize[p, 0] }.sum
puts patterns.map { |p| summarize[p, 1] }.sum
