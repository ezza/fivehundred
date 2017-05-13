class Game < ActiveRecord::Base
  has_many :hands
  has_many :bids
  has_many :cards
  has_many :tricks
  has_one :kitty

  def deal
    deck = Deck.cards.shuffle

    4.times do |i|
      hand = hands.new
      hand.bid_order = i
      hand.save!
      10.times do
        hand.cards.create!(deck.pop.merge(game: self))
      end
    end

    deck.each do |card|
      self.cards.create!(card)
    end
  end

  def award_bid
    return unless bids.inactive.count >= 3

    winning_bid = bids.active.last

    update_attributes(trump_suit: winning_bid.suit)

    cards.unassigned.each do |card|
      card.update_attributes(hand: winning_bid.hand)
    end

    cards.trump(trump_suit).update_all(is_trump: true)

    winning_bid.hand.choose_kitty
  end

end
