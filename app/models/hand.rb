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
    else
      worst_card
    end.lead
  end

  def follow(suit = game.tricks.last.cards.first.suit)
    if suit == trump_suit
      follow_trump
    else cards.non_trump.in_play.for_suit(suit).any?
      follow_non_trump(suit)
    end.play
  end

  def follow_trump
    highest_trump
  end

  def follow_non_trump(suit)
    if cant_follow_suit?(suit) && ( no_trumps? || partner_winning? )
      worst_card
    elsif cant_follow_suit?(suit)
      lowest_trump
    elsif partner_winning? && last_to_play?
      lowest_for_suit(suit)
    elsif last_to_play?
      lowest_winner(suit) || lowest_for_suit(suit)
    elsif highest_for_suit(suit).highest_in_suit?
      highest_for_suit(suit)
    elsif partner_winning?
      lowest_beater(suit) || lowest_for_suit(suit)
    else
      lowest_for_suit(suit)
    end
  end

  def have_highest_trump_in_game
    highest_trump == game.cards.in_play.first
  end

  def winning_card_strength
    game.tricks.last.cards_played.maximum(:strength)
  end

  def last_to_play?
    [3, -1].include?(bid_order - game.tricks.last.cards_played.first.hand.bid_order)
  end

  def cant_follow_suit?(suit)
    !for_suit(suit).any?
  end

  def partner_winning?
    game.tricks.last.leading_hand.bid_order % 2 == bid_order % 2
  end

  def no_trumps?
    !cards.trump.in_play.any?
  end

  def highest_trump
    cards.in_play.first
  end

  def highest_in_game_for_a_suit
    cards.non_trump.in_play.detect { |card| card.highest_in_suit? }
  end

  def highest_for_suit(suit)
    for_suit(suit).in_play.first
  end

  def lowest_trump
    cards.trump.in_play.last
  end

  def lowest_for_suit(suit)
    for_suit(suit).in_play.last
  end

  def lowest_winner(suit)
    for_suit(suit).reverse.detect { |card| card.strength > winning_card_strength }
  end

  def lowest_beater(suit)
    for_suit(suit).where("strength > ?", winning_card_strength.floor + 2)
      .where("strength < 12")
      .last
  end

  def for_suit(suit)
    cards.non_trump.for_suit(suit).in_play
  end

  def trump_count
    cards.trump.in_play.size
  end

  def shortest_suit
    cards.non_trump.in_play.pluck(:suit).uniq.sort_by do |suit|
      [for_suit(suit).size, for_suit(suit).maximum(:strength)]
    end.first
  end

  def worst_card
    cards.non_trump.in_play.where(suit: shortest_suit).last || cards.in_play.last
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
