class Hand < ActiveRecord::Base
  belongs_to :game
  has_many :cards
  has_many :bids
  has_many :won_tricks, foreign_key: :won_by_hand_id

  delegate :trump_suit, to: :game

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
    cards.by_strength.last(3).each do |card|
      card.update_attributes!(hand: nil)
    end
  end

  def lead
    if have_highest_trump_in_game
      highest_trump
    elsif trump_count > 1
      cards.trump.in_play.last
    elsif highest_in_game_for_a_suit
      highest_in_game_for_a_suit
    elsif shortest_suit
      cards.non_trump.in_play.where(suit: shortest_suit).last
    else
      cards.in_play.last
    end.play
  end

  def have_highest_trump_in_game
    highest_trump == game.cards.in_play.first
  end

  def highest_trump
    cards.in_play.first
  end

  def highest_in_game_for_a_suit
    cards.non_trump.in_play.detect do |card|
      card == game.cards.non_trump.where(suit: card.suit).in_play.first
    end
  end

  def trump_count
    cards.trump.in_play.size
  end

  def shortest_suit
    cards.non_trump.in_play.pluck(:suit).uniq.sort_by do |suit|
      cards.non_trump.in_play.where(suit: suit).size
    end.first
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
    cards.where(rank: 'Jack').where("suit = ? or suit = ?", suit, Deck.match(suit)).size
  end

  def non_trump_ace_count(suit)
    cards.where(rank: 'Ace').where.not(suit: suit).size
  end
end
