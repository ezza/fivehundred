class Trick < ActiveRecord::Base
  has_many :cards
  belongs_to :game
  belongs_to :trick_winner, foreign_key: :won_by_hand_id, class_name: Hand

  def cards_played
    cards.order(:updated_at)
  end

  def card_lead
    cards.order(:updated_at).first
  end

  def suit_lead
    if card_lead.is_trump
      game.trump_suit
    else
      card_lead.suit
    end
  end

  def leading_hand
    if cards.any? &:is_trump
      cards
    else
      cards.for_suit(suit_lead)
    end.order(:strength).reverse.first.hand
  end

  def next_player_id
    game.hands.find_by(
      bid_order: (cards_played.last.hand.bid_order + 1) % 4
    ).id
  end

  def last_player_order
    cards_played.last.hand.bid_order
  end
end
