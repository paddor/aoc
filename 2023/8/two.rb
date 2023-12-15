#! /bin/env -S ruby --jit

class Network
  def self.parse(input)
    instructions  = input[/\A[LR]+/].chars.map { |ins| ins == 'R' ? :right : :left }
    nodes_by_name = input.scan(/^(\w+) = \((\w+), (\w+)\)/).to_h do |name, left, right|
      node = Node.new(name, left, right)
      [name, node]
    end

    nodes_by_name.each_value do |node|
      node.left  = nodes_by_name.fetch node.left
      node.right = nodes_by_name.fetch node.right
    end

    Network.new instructions, nodes_by_name.values
  end


  def initialize(instructions, nodes)
    @instructions = instructions
    @nodes        = nodes
  end


  def path(start)
    node = start

    Enumerator.new do |yielder|
      @instructions.cycle do |ins|
        node = node.send ins
        yielder << node
      end
    end
  end


  def period(node)
    path(node).find_index(node) + 1
  end


  def steps
    nodes   = @nodes.select(&:start_node?).map { |node| path(node).find(&:final_node?) }
    periods = nodes.map { |node| period node }

    periods.reduce { |lcm, period| lcm.lcm period }
  end


  class Node
    attr_reader :name
    attr_accessor :left, :right


    def initialize(name, left, right)
      @name       = name
      @left       = left
      @right      = right
      @start_node = name.end_with? 'A'
      @final_node = name.end_with? 'Z'
    end


    def start_node? = @start_node
    def final_node? = @final_node
  end
end


if ARGV.first == '--test'
  result = Network.parse(DATA.read).steps
  puts result
  puts "Test result: #{result == 6 ? 'OK' : 'NOK'}"
else
  puts Network.parse($<.read).steps
end

__END__
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
