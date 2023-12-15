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
      tally  = @hand.delete('J').chars.tally.values

      case jokers
      when 5, 4
        :five_of_a_kind
      when 3
        if tally.include? 2
          :five_of_a_kind
        else
          :four_of_a_kind
        end
      when 2
        if tally.include? 3
          :five_of_a_kind
        elsif tally.include? 2
          :four_of_a_kind
        else
          :three_of_a_kind
        end
      when 1
        if tally.include? 4
          :five_of_a_kind
        elsif tally.include? 3
          :four_of_a_kind
        elsif tally.count(2) >= 2
          :full_house
        elsif tally.include? 2
          :three_of_a_kind
        else
          :one_pair
        end
      else
        if tally.include? 5
          :five_of_a_kind
        elsif tally.include? 4
          :four_of_a_kind
        elsif tally.include?(3) && tally.include?(2)
          :full_house
        elsif tally.include? 3
          :three_of_a_kind
        elsif tally.count(2) >= 2
          :two_pair
        elsif tally.include?(2)
          :one_pair
        else
          :high_card
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
