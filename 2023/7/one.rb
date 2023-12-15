#! /bin/env -S ruby --jit

class CamelCards

  def self.parse(input)
    hands = input.scan(/^(\S+) (\d+)/).map do |hand, bid|
      Hand.new hand, bid.to_i
    end

    CamelCards.new hands
  end


  def initialize(hands)
    @hands = hands
  end


  def ranked_hands
    sorted_hands = @hands.sort_by { |hand| [hand.strength, hand.cards] }
    sorted_hands.map.with_index(1) { |hand, rank| [hand, rank] }.reverse
  end


  def winnings
    ranked_hands.map { |hand, rank| hand.bid * rank }
  end


  class Hand
    TYPES = %i[
      high_card
      one_pair
      two_pair
      three_of_a_kind
      full_house
      four_of_a_kind
      five_of_a_kind
    ]

    attr_reader :hand, :bid


    def initialize(hand, bid)
      @hand  = hand
      @bid   = bid
    end


    def strength
      TYPES.index type
    end


    def type
      sorted_hand = @hand.chars.sort.join

      case sorted_hand
      when /(.)\1{4}/
        :five_of_a_kind
      when /(.)\1{3}/
        :four_of_a_kind
      when /(.)\1{2}(.)\2|(.)\3(.)\4{2}/
        :full_house
      when /(.)\1{2}/
        :three_of_a_kind
      when /(.)\1.?(.)\2/
        :two_pair
      when /(.)\1/
        :one_pair
      else
        :high_card
      end
    end


    def cards
      @cards ||= @hand.chars.map { |label| Card.new label }
    end


    def <=>(other)
      [strength, cards] <=> [other.strength, other.cards]
    end
  end


  class Card
    RANKS = %w[2 3 4 5 6 7 8 9 T J Q K A]


    def initialize(label)
      @label = label
    end


    def strength
      RANKS.index @label
    end


    def <=>(other)
      strength <=> other.strength
    end
  end
end


if ARGV.first == '--test'
  result = CamelCards.parse(DATA.read).winnings.sum
  puts result
  puts "Test result: #{result == 6440 ? 'OK' : 'NOK'}"
else
  puts CamelCards.parse($<.read).winnings.sum
end

__END__
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
