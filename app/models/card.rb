class Card < ActiveRecord::Base
  belongs_to :hand
  belongs_to :game

  def self.unassigned
    where(hand: nil)
  end

  def strength(suit)
    
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
      rank
    end
  end

  def to_s
    "#{rank} of #{suit}"
  end
end
