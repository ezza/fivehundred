class Hand < ActiveRecord::Base
  include Ai::Mimi

  belongs_to :game
  has_many :cards
  has_many :bids
  has_many :won_tricks, class_name: Trick, foreign_key: :won_by_hand_id

  belongs_to :user

  delegate :trump_suit, to: :game

  def name
    if user
      if user.email == 'admin@example.com'
        'Giles'
      else
        user.email.split('@')[0]
      end
    end
  end

  def match_user
    game.match.match_users.find_by(user: user)
  end

  def team_bid_string
    bid = bids.last.to_s
    bid == "0 Pass" ? partner.bids.last : bid
  end

  def team_won_tricks_count
    won_tricks.size + partner.won_tricks.size
  end

  def can_bid?
    game.cards.any? && game.next_bidder_id == id
  end

  def make_bid(bid = nil)
    return ai_bid.save unless bid

    if bid == "Pass"
      bids.new(suit: "Pass", tricks: 0)
    else
      tricks, suit = bid.split(' ')
      bids.new(suit: suit, tricks: tricks)
    end.save
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
    if suit && rank
      suit = nil if suit.blank?
      card = cards.find_by(suit: suit, rank: rank)
    else
      card = ai_play
    end

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
end
