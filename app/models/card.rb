class Card < ActiveRecord::Base
  belongs_to :hand
  belongs_to :game

  def self.unassigned
    where(hand: nil)
  end

  def strength(trump_suit)
    value + if suit == trump_suit
      15
    else
      Deck.value(suit).to_f / 200
    end
  end

  def value
    case rank
    when 'Ace'
      14
    when 'King'
      13
    when 'Queen'
      12
    when 'Jack'
      11
    else
      rank.to_i
    end
  end

  def to_s
    "#{rank} of #{suit}"
  end
end
