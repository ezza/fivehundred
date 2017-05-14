class Trick < ActiveRecord::Base
  has_many :cards

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
    cards.order(:strength).reverse.first.hand
  end
end
