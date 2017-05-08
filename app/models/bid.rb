class Bid < ActiveRecord::Base
  belongs_to :hand
  belongs_to :game
  before_create :set_game

  def self.active
    where.not(suit: 'Pass')
  end

  def score
    Deck.value(suit) + trick_score
  end

  def trick_score
    (tricks - 6) * 100
  end

  protected

  def set_game
    self.game = hand.game
  end

end
