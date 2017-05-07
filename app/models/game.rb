class Game < ActiveRecord::Base
  has_many :hands
  has_one :kitty

  def deal
    deck = Deck.cards.shuffle

    4.times do |i|
      hand = hands.new
      hand.bid_order = i
      hand.save!
      10.times do
        hand.cards.create!(deck.pop)
      end
    end
  end
end
