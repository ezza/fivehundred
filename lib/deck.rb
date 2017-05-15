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

  def self.match(suit)
    case suit
    when 'Hearts'
      'Diamonds'
    when 'Diamonds'
      'Hearts'
    when 'Clubs'
      'Spades'
    when 'Spades'
      'Clubs'
    end
  end

  def self.value(suit)
    case suit
    when 'Hearts'
      100
    when 'Diamonds'
      80
    when 'Clubs'
      60
    when 'Spades'
      40
    end
  end

  def self.pictogram(suit)
    case suit
    when 'Hearts'
      "♡"
    when 'Diamonds'
      "♢"
    when 'Clubs'
      "♧"
    when 'Spades'
      "♤"
    when nil
      "🃏"
    end
  end

end
