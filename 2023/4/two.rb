#! /bin/env ruby

class Pile
  def self.parse(input)
    cards = input.each_line.map do |line|
      Card.parse line
    end

    Pile.new cards
  end


  def initialize(cards)
    @cards = cards
  end


  def effective_cards(range = 0.., list = [])
    # More idiomatic
    @cards[range].each_with_index do |card, i|
      list << card
      if card.matches.any?
        base       = range.begin + i + 1
        copy_range = base ... base + card.matches.size
        effective_cards(copy_range, list)
      end
    end
    list

    # Runs in about 50% time because it creates less intermediate Arrays
    # i = 0
    # range.each do |card_index|
    #   card = @cards[card_index] or break
    #   list << card
    #   if card.matches.any?
    #     base       = range.begin + i + 1
    #     copy_range = base ... base + card.matches.size
    #     effective_cards(copy_range, list)
    #   end
    #   i += 1
    # end
    # list
  end

end


class Card
  def self.parse(line)
    _, numbers   = line.split ':', 2
    winning, own = numbers.split('|', 2).map { |str| str.split.map(&:to_i) }

    Card.new winning, own
  end


  attr_reader :matches


  def initialize(winning, own)
    @matches = winning & own
  end
end


if ARGV.first == '--test'
  result = Pile.parse(DATA).effective_cards.size
  puts "Sum: #{result}"
  puts "Test result: #{result == 30 ? 'OK' : 'NOK'}"
else
  puts Pile.parse($<).effective_cards.size
end

__END__
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
