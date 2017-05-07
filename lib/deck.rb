class Deck
  SUITS = %w[Hearts Diamonds Clubs Spades]
  RED_SUITS   = SUITS[0..1]
  BLACK_SUITS = SUITS[2..3]
  RED_RANKS   = [*4..10, 'Jack', 'Queen', 'King', 'Ace']
  BLACK_RANKS = RED_RANKS[1..-1]

  def self.cards
    (
      RED_SUITS.map do |suit|
        RED_RANKS.map do |rank|
          { rank: rank, suit: suit }
        end
      end + BLACK_SUITS.map do |suit|
        BLACK_RANKS.map do |rank|
          { rank: rank, suit: suit }
        end
      end + [{ rank: 'Joker', suit: nil }]
    ).flatten
  end

end
