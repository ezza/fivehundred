require 'rails_helper'

RSpec.describe Hand, type: :model do
  before do
    @game = Game.create
    @hand = @game.hands.create(bid_order: 1)
  end

  describe "Hearts hand" do
    before do
      @hand.cards.create(rank: 'Jack', suit: "Diamonds")
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

    describe "bowers" do
    end
  end


  describe "first bid" do
    it "bids with four trumps including bower" do
      @hand.cards.create(rank: 'Jack', suit: "Hearts")
      @hand.cards.create(rank: 'Ace', suit: "Hearts")
      @hand.cards.create(rank: 10, suit: "Hearts")
      @hand.cards.create(rank: 9, suit: "Hearts")

      @hand.make_bid

      expect(
        @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
      ).to eq({
        suit: 'Hearts', tricks: 6
      })
    end

    it "bids with three trumps and the left bower" do
      @hand.cards.create(rank: 'Jack', suit: "Diamonds")
      @hand.cards.create(rank: 'Ace', suit: "Hearts")
      @hand.cards.create(rank: 10, suit: "Hearts")
      @hand.cards.create(rank: 9, suit: "Hearts")

      @hand.make_bid

      expect(
        @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
      ).to eq({
        suit: 'Hearts', tricks: 6
      })
    end

    it "bids with five trumps and no bower" do
      @hand.cards.create(rank: 'Ace', suit: "Hearts")
      @hand.cards.create(rank: 'Queen', suit: "Hearts")
      @hand.cards.create(rank: 10, suit: "Hearts")
      @hand.cards.create(rank: 9, suit: "Hearts")
      @hand.cards.create(rank: 4, suit: "Hearts")

      @hand.make_bid

      expect(
        @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
      ).to eq({
        suit: 'Hearts', tricks: 6
      })
    end

    it "passes with four trumps and no bower" do
      @hand.cards.create(rank: 'Queen', suit: "Hearts")
      @hand.cards.create(rank: 10, suit: "Hearts")
      @hand.cards.create(rank: 9, suit: "Hearts")
      @hand.cards.create(rank: 4, suit: "Hearts")

      @hand.make_bid

      expect(
        @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
      ).to eq({
        suit: 'Pass', tricks: 0
      })
    end
  end

  describe "following a bid of 6 hearts" do
    before do
      @hand_two = @game.hands.create!(bid_order: 2)
      @hand_two.bids.create(suit: 'Hearts', tricks: 6)
    end

    it "bids 7 with a black hand" do
      @hand.cards.create(rank: 'Jack', suit: "Clubs")
      @hand.cards.create(rank: 'Ace', suit: "Spades")
      @hand.cards.create(rank: 10, suit: "Spades")
      @hand.cards.create(rank: 9, suit: "Spades")
      @hand.cards.create(rank: 'Ace', suit: "Diamonds")
      @hand.make_bid

      expect(
        @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
      ).to eq({
        suit: 'Spades', tricks: 7
      })
    end

    it "passes with a red hand" do
      @hand.cards.create(rank: 'Jack', suit: "Diamonds")
      @hand.cards.create(rank: 'Ace', suit: "Hearts")
      @hand.cards.create(rank: 10, suit: "Hearts")
      @hand.cards.create(rank: 9, suit: "Hearts")
      @hand.make_bid

      expect(
        @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
      ).to eq({
        suit: 'Pass', tricks: 0
      })
    end

    it "bids the colour not bid by the opponents" do
      @hand.cards.create(rank: 'Jack', suit: "Diamonds")
      @hand.cards.create(rank: 'Ace', suit: "Hearts")
      @hand.cards.create(rank: 10, suit: "Hearts")
      @hand.cards.create(rank: 9, suit: "Hearts")
      @hand.cards.create(rank: 8, suit: "Hearts")
      @hand.cards.create(rank: 'Jack', suit: "Clubs")
      @hand.cards.create(rank: 'Ace', suit: "Spades")
      @hand.cards.create(rank: 10, suit: "Spades")
      @hand.cards.create(rank: 9, suit: "Spades")
      @hand.make_bid

      expect(
        @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
      ).to eq({
        suit: 'Spades', tricks: 7
      })
    end

    describe "with a partner bid of 6 clubs" do
      before do
        @hand.bids.create(suit: 'Clubs', tricks: 6)
        @hand_two = @game.hands.create!(bid_order: 2)
        @hand_two.bids.create(suit: 'Hearts', tricks: 6)
        @hand_three = @game.hands.create!(bid_order: 3)
      end

      it "bids 7 with a black hand" do
        @hand_three.cards.create(rank: 'Jack', suit: "Clubs")
        @hand_three.cards.create(rank: 'Ace', suit: "Spades")
        @hand_three.cards.create(rank: 10, suit: "Spades")
        @hand_three.cards.create(rank: 9, suit: "Spades")
        @hand_three.make_bid

        expect(
          @hand_three.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
        ).to eq({
          suit: 'Clubs', tricks: 7
        })
      end

      it "passes with a red hand" do
        @hand_three.cards.create(rank: 'Jack', suit: "Diamonds")
        @hand_three.cards.create(rank: 'Ace', suit: "Hearts")
        @hand_three.cards.create(rank: 10, suit: "Hearts")
        @hand_three.cards.create(rank: 9, suit: "Hearts")
        @hand_three.make_bid

        expect(
          @hand_three.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
        ).to eq({
          suit: 'Pass', tricks: 0
        })
      end

      it "changes to the partners suit" do
        @hand_three.cards.create(rank: 9, suit: "Clubs")
        @hand_three.cards.create(rank: 8, suit: "Clubs")
        @hand_three.cards.create(rank: 'Jack', suit: "Clubs")
        @hand_three.cards.create(rank: 'Queen', suit: "Spades")
        @hand_three.cards.create(rank: 10, suit: "Spades")
        @hand_three.cards.create(rank: 9, suit: "Spades")
        @hand_three.make_bid

        expect(
          @hand_three.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
        ).to eq({
          suit: 'Clubs', tricks: 7
        })
      end
    end
  end

end
