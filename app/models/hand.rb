class Hand < ActiveRecord::Base
  belongs_to :game
  has_many :cards
  has_many :bids

  def make_bid
    tricks = 6

    bids.create(suit: strongest_suit, tricks: tricks)
  end

  def strongest_suit
    Deck::SUITS.sort_by do |suit|
      strength(suit)
    end.last
  end

  def strength(suit)
    cards.where(suit: suit).count +
    cards.where(rank: 'Ace').where.not(suit: suit).count +
    cards.where(rank: 'Joker').count * 2
  end
end
