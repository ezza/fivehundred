class Hand < ActiveRecord::Base
  belongs_to :game
  has_many :cards
  has_many :bids
  has_many :won_tricks, class_name: Trick, foreign_key: :won_by_hand_id

  belongs_to :user

  delegate :trump_suit, to: :game

  AI_NAMES = [
    'Lucille',
    'Mimi',
    'Standford',
    'Doyle'
  ]

  def name
    if user
      if user.email == 'admin@example.com'
        'Giles'
      else
        user.email.split('@')[0]
      end
    else
      AI_NAMES[bid_order]
    end
  end

  def can_bid?
    game.cards.any? && game.next_bidder_id == id
  end

  def make_bid(bid = nil)
    return ai_bid unless bid

    if bid == "Pass"
      bids.new(suit: "Pass", tricks: 0)
    else
      tricks, suit = bid.split(' ')
      bids.new(suit: suit, tricks: tricks)
    end.save
  end

  def ai_bid
    strongest = strongest_suit
    strength = strength(strongest_suit)

    bid = bids.new(suit: strongest, tricks: 6)
    while bid.score <= game.highest_bid.try(:score).to_i
      bid.tricks += 1
      strength -= 1
    end

    unless strength > 2
      bid.suit, bid.tricks = 'Pass', 0
    end

    bid.save
  end

  def can_play?
    false unless game.bid_winner
    if game.tricks.count == 0
      game.bid_winner == self
    elsif !game.pending_trick?
      game.tricks.last.trick_winner == self
    elsif game.tricks.last.cards_played.size < 4
      game.tricks.last.next_player_id == id
    end
  end

  def play(suit: nil, rank: nil)
    return ai_play unless suit && rank

    card = cards.find_by(suit: suit, rank: rank)

    if game.pending_trick?
      card.play
    else
      card.lead
    end
  end

  def discard(suit: nil, rank: nil)
    card = cards.find_by(suit: suit, rank: rank)
    card.update_attributes!(hand: nil)
  end

  def ai_play
    if game.pending_trick?
      follow
    else
      lead
    end
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

  def follow(suit = game.tricks.last.suit_lead)
    if cant_follow_suit?(suit) && cant_trump?(suit)
      worst_card
    elsif cant_follow_suit?(suit)
      lowest_trump
    elsif partner_winning? && last_to_play?
      lowest_for_suit(suit)
    elsif last_to_play?
      lowest_winner(suit) || lowest_for_suit(suit)
    elsif have_highest_card_for_trick?(suit)
      highest_for_suit(suit)
    elsif partner_winning?
      lowest_beater(suit) || lowest_for_suit(suit)
    else
      lowest_for_suit(suit)
    end.play
  end

  def have_highest_trump_in_game
    highest_trump == game.cards.in_play.first
  end

  def have_highest_card_for_trick?(suit)
    highest_for_suit(suit).highest_in_suit? &&
    winning_card_strength < highest_for_suit(suit).strength
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

  def cant_trump?(suit)
    no_trumps? || partner_winning? || suit == trump_suit
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
    if suit == trump_suit
      cards.trump.in_play
    else
      cards.non_trump.for_suit(suit).in_play
    end
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
    right_bower_count(suit) * 1.2 +
    left_bower_count(suit) * 1 +
    non_bower_count(suit).to_f * 0.5 +
    trump_count_for(suit, "ace").to_f * 0.3 +
    trump_count_for(suit, "king").to_f * 0.2 +
    trump_count_for(suit, "queen").to_f * 0.1 +
    non_trump_ace_count(suit) * 0.9 +
    cards.where(rank: 'Joker').size * 1.5
  end

  def non_bower_count(suit)
    cards.where(suit: suit).where.not(rank: 'Jack').size
  end

  def bower_count(suit)
    cards.where(rank: 'Jack').where("suit = ? or suit = ?", suit, Deck.match(suit)).size
  end

  def left_bower_count(suit)
    cards.where(rank: 'Jack').where("suit = ?", Deck.match(suit)).size
  end

  def right_bower_count(suit)
    cards.where(rank: 'Jack').where("suit = ?", suit).size
  end

  def trump_count_for(suit, rank)
    cards.where(rank: rank).where(suit: suit).size
  end

  def non_trump_ace_count(suit)
    cards.where(rank: 'Ace').where.not(suit: suit).size
  end
end
