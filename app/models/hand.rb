class Hand < ActiveRecord::Base
  belongs_to :game
  has_many :cards
  has_many :bids


  def make_bid
    strongest = strongest_suit
    strength = strength(strongest_suit)

    bid = bids.new(suit: strongest, tricks: 6)
    while bid.score <= highest_bid.try(:score).to_i
      bid.tricks += 1
      strength -= 0.5
    end

    unless strength > 2
      bid.suit, bid.tricks = 'Pass', 0
    end

    bid.save
  end

  def choose_kitty
    
    
    # Remove each card in turn, discard the lowest value card that has the lowest score decrease
  end

  def highest_bid
    game.bids.active.last
  end

  def highest_partner_bid
    game.bids.active.where(hand: partner).last
  end

  def highest_opponent_bid
    game.bids.active.where.not(hand: partner).last
  end

  def partner
    game.hands.where(bid_order:
      (bid_order + 2) % 4
    )
  end

  def strongest_suit
    Deck::SUITS.sort_by do |suit|
      strength(suit)
    end.last
  end

  def strength(suit)
    score = internal_strength(suit)

    score += 1.3 if highest_partner_bid.try(:suit) == suit
    score += 0.3 if highest_partner_bid.try(:suit) == Deck.match(suit)
    score -= 1.3 if highest_opponent_bid.try(:suit) == suit
    score -= 0.3 if highest_opponent_bid.try(:suit) == Deck.match(suit)

    score
  end

  def internal_strength(suit)
    bower_count(suit) +
    non_bower_count(suit).to_f/2 +
    non_trump_ace_count(suit) +
    cards.where(rank: 'Joker').size
  end

  def non_bower_count(suit)
    cards.where(suit: suit).where.not(rank: 'Jack').size
  end

  def bower_count(suit)
    left_suit = Deck.match(suit)
    cards.where(rank: 'Jack').where("suit = ? or suit = ?", suit, left_suit).size
  end

  def non_trump_ace_count(suit)
    cards.where(rank: 'Ace').where.not(suit: suit).size
  end
end
