class Trick < ActiveRecord::Base
  has_many :cards

  def cards_played
    cards.order(:updated_at)
  end

  def leading_hand
    cards.order(:strength).reverse.first.hand
  end
end
