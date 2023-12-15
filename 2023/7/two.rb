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
    @hands.sort_by { |h| [h.strength, h.cards] }.map.with_index(1) { |h, rank| [h, rank] }.reverse
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

    attr_reader :hand, :bid, :strength, :cards


    def initialize(hand, bid)
      @hand     = hand
      @bid      = bid
      @strength = TYPES.index type
      @cards    = @hand.chars.map { |label| Card.new label }
    end


    def type
      jokers = @hand.count 'J'
      hand   = @hand.chars.sort.join.delete 'J'

      case jokers
      when 5, 4
        :five_of_a_kind
      when 3
        case hand # 2 chars
        when /(.)\1/ then :five_of_a_kind
        else :four_of_a_kind
        end
      when 2
        case hand # 3 chars
        when /(.)\1\1/ then :five_of_a_kind
        when /(.)\1/   then :four_of_a_kind
        else :three_of_a_kind
        end
      when 1
        case hand # 4 chars
        when /(.)\1{3}/   then :five_of_a_kind
        when /(.)\1\1/    then :four_of_a_kind
        when /(.)\1(.)\2/ then :full_house
        when /(.)\1/      then :three_of_a_kind
        else :one_pair
        end
      else
        case hand # 5 chars
        when /(.)\1{4}/                  then :five_of_a_kind
        when /(.)\1{3}/                  then :four_of_a_kind
        when /(.)\1\1(.)\2|(.)\3(.)\4\4/ then :full_house
        when /(.)\1\1/                   then :three_of_a_kind
        when /(.)\1.?(.)\2/              then :two_pair
        when /(.)\1/                     then :one_pair
        else :high_card
        end
      end
    end
  end


  class Card
    RANKS = %w[J 2 3 4 5 6 7 8 9 T Q K A]

    attr_reader :strength


    def initialize(label)
      @label    = label
      @strength = RANKS.index @label
    end


    def <=>(other)
      strength <=> other.strength
    end
  end
end


if ARGV.first == '--test'
  result = CamelCards.parse(DATA.read).winnings.sum
  puts result
  puts "Test result: #{result == 5905 ? 'OK' : 'NOK'}"
else
  puts CamelCards.parse($<.read).winnings.sum
end

__END__
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
