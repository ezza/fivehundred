class Game < ActiveRecord::Base
  has_many :hands
  has_many :bids
  has_many :cards
  has_many :tricks
  has_one :kitty

  belongs_to :match
  belongs_to :bid_winner, foreign_key: :bid_winner_id, class_name: Hand

  after_create :create_hands

  def create_hands
    4.times do |i|
      hands.create(bid_order: i)
    end
  end

  def next_action_ai?
    return false if can_award_game?

    can_award_trick? ||
    can_award_bid? ||
    hands.detect do |hand|
      next unless hand.user.try(:is_ai?)
      hand.can_bid? || hand.can_play?
    end
  end

  def perform_ai_action
    return false if can_award_game?

    award_trick if can_award_trick?
    award_bid if can_award_bid?

    hands.each do |hand|
      next unless hand.user.is_ai?

      hand.make_bid if hand.can_bid?
      hand.play if hand.can_play?
    end
  end

  def deal
    return unless can_deal?

    self.transaction do
      hands.where(user: nil).each_with_index do |hand, i|
        user = User.where(is_ai: true).offset(i).first
        hand.update_attributes(user: user)
        match.users << user
      end

      deck = Deck.cards.shuffle

      hands.each do |hand|
        10.times do
          hand.cards.create!(deck.pop.merge(game: self))
        end
      end

      deck.each do |card|
        self.cards.create!(card)
      end

      raise ActiveRecord::Rollback if reload.started?

      update_attributes!(started: true)
    end
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

    winning_bid.hand.choose_kitty if winning_bid.hand.user.is_ai?
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

  def score_game
    trick_count = bid_winner.team_won_tricks_count

    if trick_count >= highest_bid.tricks
      score = highest_bid.score
    else
      score = 0 - highest_bid.score
    end

    hands.each do |hand|
      match_user = match.match_users.find_by(user: hand.user)
      if [bid_winner, bid_winner.partner].include? hand
        match_user.score += score
      else
        match_user.score += (10 - trick_count) * 10
      end
      match_user.save
    end
  end

  def award_game
    return unless can_award_game?

    self.transaction do
      score_game

      raise ActiveRecord::Rollback if reload.played?

      update_attributes!(played: true)
    end

    match.games.create.tap do |game|
      game.hands.each do |hand|
        hand.update_attributes(user: hands.find_by(bid_order: (hand.bid_order + 1) % 4).user)
      end
    end
  end

  def can_award_game?
    tricks.where.not(trick_winner: nil).size > 9
  end

  def can_deal?
    cards.size == 0
  end

  def last_trick_cards
    tricks.where.not(won_by_hand_id: nil).last.try(:cards_played) || []
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
    bids.active.size >= 1
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
