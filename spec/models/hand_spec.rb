require 'rails_helper'

RSpec.describe Hand, type: :model do
  before do
    @hand = Hand.create
  end

  describe "Hearts hand" do
    before do
      @hand.cards.create(rank: 'Jack', suit: "Hearts")
      @hand.cards.create(rank: 'Ace', suit: "Hearts")
      @hand.cards.create(rank: 10, suit: "Hearts")
      @hand.cards.create(rank: 9, suit: "Hearts")
      @hand.cards.create(rank: 8, suit: "Hearts")
      @hand.cards.create(rank: 'Ace', suit: "Clubs")
      @hand.cards.create(rank: 6, suit: "Spades")
      @hand.cards.create(rank: 10, suit: "Spades")
      @hand.cards.create(rank: 'Queen', suit: "Diamonds")
    end

    describe "strength" do
      it "prefers Hearts" do
        expect(@hand.strength("Hearts") > @hand.strength("Spades"))
      end

      it "ranks spades second" do
        expect(@hand.strength("Spades") > @hand.strength("Diamonds"))
      end

      it "ranks diamonds third" do
        expect(@hand.strength("Diamonds") > @hand.strength("Clubs"))
      end
    end

    describe "bid" do
      it "creates a bid of six hearts" do
        @hand.make_bid

        expect(
          @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
        ).to eq({
          suit: 'Hearts', tricks: 6
        })
      end
    end
  end


end
