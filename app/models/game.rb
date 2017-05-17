class Game < ActiveRecord::Base
  has_many :hands
  has_many :bids
  has_many :cards
  has_many :tricks
  has_one :kitty
  belongs_to :bid_winner, foreign_key: :bid_winner_id, class_name: Hand

  def self.create
    game = super
    4.times do |i|
      hand = game.hands.new
      hand.bid_order = i
      hand.save!
    end
    game
  end

  def next_action_ai?
    can_award_trick? ||
    can_award_bid? ||
    hands.detect do |hand|
      next if hand.user
      hand.can_bid? || hand.can_play?
    end
  end

  def perform_ai_action
    award_trick if can_award_trick?
    award_bid if can_award_bid?

    hands.each do |hand|
      next if hand.user

      hand.make_bid if hand.can_bid?
      hand.play if hand.can_play?
    end
  end

  def join(user)
    [hands[0], hands[2], hands[1], hands[3]].detect do |hand|
      hand.user.nil?
    end.update_attributes(user: user)
  end

  def deal
    deck = Deck.cards.shuffle

    hands.each do |hand|
      10.times do
        hand.cards.create!(deck.pop.merge(game: self))
      end
    end

    deck.each do |card|
      self.cards.create!(card)
    end

    update_attributes!(started: true)
  end

  def award_bid
    return unless bidding_complete?

    winning_bid = bids.active.last

    update_attributes(bid_winner: winning_bid.hand)
    update_attributes(trump_suit: winning_bid.suit)
    update_attributes(tricks_bid: winning_bid.tricks)

    cards.unassigned.update_all(hand_id: winning_bid.hand_id)

    cards.trumps_when(trump_suit).update_all(is_trump: true)

    set_card_strength

    winning_bid.hand.choose_kitty unless winning_bid.hand.user
  end

  def can_award_bid?
    bidding_complete? &&
    !bid_winner
  end

  def award_trick
    return unless can_award_trick?

    tricks.last.update_attributes!(trick_winner: tricks.last.leading_hand)
  end

  def can_award_trick?
    tricks.last &&
    !tricks.last.won_by_hand_id &&
    tricks.last.cards_played.size >= 4
  end

  def can_deal?
    cards.size == 0
  end

  def current_trick_cards
    if pending_trick?
      tricks.last.cards_played
    else
      []
    end
  end

  def available_bids
    Deck.bids_above(highest_bid.try(:score).to_i)
  end

  def highest_bid
    bids.active.last
  end

  def bidding_complete?
    bids.inactive.size >= 3 &&
    bids.active.size == 1
  end

  def pending_trick?
    tricks.last && !tricks.last.try(:won_by_hand_id) #&& tricks.last.cards_played.size < 4
  end

  def set_card_strength
    cards.each do |card|
      card.update_attributes(strength: card.calculate_strength(trump_suit))
    end
  end

  def bidders
    hands.pluck(:id) - bids.inactive.map(&:hand_id).uniq
  end

  def next_bidder_id
    if bid_winner || bids.inactive.size >= 3
      nil
    elsif bids.active.any?
      index = bidders.index(bids.active.last.hand_id) + 1
      bidders[index % bidders.length]
    elsif bids.inactive.any?
      bidders.first
    else
      hands.first.id
    end
  end

end
