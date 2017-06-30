class Card < ActiveRecord::Base
  belongs_to :hand
  belongs_to :game
  belongs_to :trick

  before_save :set_strength

  def self.unassigned
    where(hand: nil)
  end

  def self.by_strength
    order('strength DESC')
  end

  def self.in_play
    in_play_unordered.by_strength
  end

  def self.in_play_unordered
    where(trick: nil).where.not(hand: nil)
  end

  def self.played
    where.not(trick: nil)
  end

  def self.trump
    where(is_trump: true)
  end

  def self.non_trump
    where(is_trump: false)
  end

  def self.for_suit(suit)
    where(suit: suit)
  end

  def self.trumps_when(suit)
    where("suit = ? or (suit = ? and rank = ?) or rank = ?", suit, Deck.match(suit), 'Jack', 'Joker')
  end

  def lead
    update_attributes!(trick: game.tricks.create)
  end

  def play
    update_attributes!(trick: game.tricks.last) if can_play?
  end

  def can_play?
    return true unless game.pending_trick?
    if game.tricks.last.card_lead.is_trump
      is_trump || hand.no_trumps?
    else
      (!is_trump && suit == game.tricks.last.suit_lead) ||
      hand.cant_follow_suit?(game.tricks.last.suit_lead)
    end
  end

  def highest_in_suit?
    self == if is_trump
      game.cards.trump.in_play.first
    else
      game.cards.non_trump.where(suit: suit).in_play.first
    end
  end

  def set_strength
    self.strength = calculate_strength(game.try(:trump_suit))
  end

  def calculate_strength(trump_suit = nil)
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
      32
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
    "#{Deck.pictogram(suit)} " + [rank, suit].compact.join(' of ')
  end
end
