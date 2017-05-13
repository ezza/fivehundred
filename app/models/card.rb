class Card < ActiveRecord::Base
  belongs_to :hand
  belongs_to :game
  belongs_to :trick

  def self.unassigned
    where(hand: nil)
  end

  def self.by_strength(suit)
    all.sort_by{ |c| c.strength(suit) }.reverse
  end

  def self.in_play
    where(trick: nil).where.not(hand: nil)
  end

  def self.trump
    where(is_trump: true)
  end

  def self.non_trump
    where(is_trump: false)
  end

  def self.trumps_when(suit)
    where("suit = ? or (suit = ? and rank = ?) or rank = ?", suit, Deck.match(suit), 'Jack', 'Joker')
  end

  def play
    update_attributes!(trick: game.tricks.create)
  end

  def strength(trump_suit)
    value + case
    when suit == trump_suit && rank == "Jack"
      20
    when suit == Deck.match(trump_suit) && rank == "Jack"
      19
    when suit == trump_suit
      15
    else
      Deck.value(suit).to_f / 200
    end
  end

  def value
    case rank
    when 'Joker'
      31
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
