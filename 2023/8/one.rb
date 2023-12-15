#! /bin/env -S ruby --jit

class Network
  INSTRUCTIONS = {
    'L' => :left,
    'R' => :right,
  }

  START = 'AAA'
  FINAL = 'ZZZ'

  def self.parse(input)
    instructions = input[/\A[LR]+/].chars.map { |ins| INSTRUCTIONS.fetch ins }
    nodes        = input.scan(/^(\w+) = \((\w+), (\w+)\)/).map.to_h do |name, left, right|
      node = Node.new(left, right)
      [name, node]
    end

    Network.new instructions, nodes
  end


  def initialize(instructions, nodes)
    @instructions = instructions
    @nodes        = nodes
  end


  def path
    Enumerator.new do |yielder|
      node  = @nodes.fetch START
      final = @nodes.fetch FINAL

      @instructions.cycle do |ins|
        yielder << node
        break if node == final
        node = @nodes.fetch node.send(ins)
      end
    end
  end


  def steps
    path.count - 1
  end


  class Node
    attr_reader :left, :right


    def initialize(left, right)
      @left  = left
      @right = right
    end

  end
end


if ARGV.first == '--test'
  result = Network.parse(DATA.read).steps
  puts result
  puts "Test result: #{result == 2 ? 'OK' : 'NOK'}"
else
  puts Network.parse($<.read).steps
end

__END__
RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)
