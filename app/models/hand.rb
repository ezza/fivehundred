class Hand < ActiveRecord::Base
  belongs_to :game
  has_many :cards
  has_many :bids

  def make_bid
    tricks = 6
    strongest = strongest_suit
    strength = strength(strongest_suit)

    unless strength > 2
      return bids.create!(suit: 'Pass', tricks: 0)
    end

    bid = bids.new(suit: strongest_suit, tricks: tricks)
    bid.tricks += 1 if bid.score <= highest_bid.try(:score).to_i
    bid.save
  end

  def highest_bid
    game.bids.active.last
  end

  def strongest_suit
    Deck::SUITS.sort_by do |suit|
      strength(suit)
    end.last
  end

  def strength(suit)
    # Number of trumps
    # Number of bowers
    bower_count(suit) +
    non_bower_count(suit).to_f/2 +
    non_trump_ace_count(suit) +
    cards.where(rank: 'Joker').count
  end

  def non_bower_count(suit)
    cards.where(suit: suit).where.not(rank: 'Jack').count
  end

  def bower_count(suit)
    left_suit = Deck.match(suit)
    cards.where(rank: 'Jack').where("suit = ? or suit = ?", suit, left_suit).count
  end

  def non_trump_ace_count(suit)
    cards.where(rank: 'Ace').where.not(suit: suit).count
  end
end
