require 'rails_helper'

RSpec.describe Hand, type: :model do
  before do
    @game = Game.create
    @hand = @game.hands.create(bid_order: 1)
  end

  def create_card(hand: @hand, rank:, suit:, is_trump: false)
    card = hand.cards.create(game: @game, rank: rank, suit: suit, is_trump: is_trump)
    card.set_strength
    card
  end

  describe "Suit order" do
    before do
      create_card(rank: 'Jack', suit: "Diamonds")
      create_card(rank: 'Ace', suit: "Hearts")
      create_card(rank: 10, suit: "Hearts")
      create_card(rank: 9, suit: "Hearts")
      create_card(rank: 8, suit: "Hearts")
      create_card(rank: 'Ace', suit: "Clubs")
      create_card(rank: 6, suit: "Spades")
      create_card(rank: 10, suit: "Spades")
      create_card(rank: 'Queen', suit: "Diamonds")
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
      create_card(rank: 'Jack', suit: "Hearts")
      create_card(rank: 'Ace', suit: "Hearts")
      create_card(rank: 10, suit: "Hearts")
      create_card(rank: 9, suit: "Hearts")

      @hand.make_bid

      expect(
        @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
      ).to eq({
        suit: 'Hearts', tricks: 6
      })
    end

    it "bids with three trumps and the left bower" do
      create_card(rank: 'Jack', suit: "Diamonds")
      create_card(rank: 'Ace', suit: "Hearts")
      create_card(rank: 10, suit: "Hearts")
      create_card(rank: 9, suit: "Hearts")

      @hand.make_bid

      expect(
        @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
      ).to eq({
        suit: 'Hearts', tricks: 6
      })
    end

    it "bids with five trumps and no bower" do
      create_card(rank: 'Ace', suit: "Hearts")
      create_card(rank: 'Queen', suit: "Hearts")
      create_card(rank: 10, suit: "Hearts")
      create_card(rank: 9, suit: "Hearts")
      create_card(rank: 4, suit: "Hearts")

      @hand.make_bid

      expect(
        @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
      ).to eq({
        suit: 'Hearts', tricks: 6
      })
    end

    it "passes with four trumps and no bower" do
      create_card(rank: 'Queen', suit: "Hearts")
      create_card(rank: 10, suit: "Hearts")
      create_card(rank: 9, suit: "Hearts")
      create_card(rank: 4, suit: "Hearts")

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
      create_card(rank: 'Jack', suit: "Clubs")
      create_card(rank: 'Ace', suit: "Spades")
      create_card(rank: 10, suit: "Spades")
      create_card(rank: 9, suit: "Spades")
      create_card(rank: 'Ace', suit: "Diamonds")
      @hand.make_bid

      expect(
        @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
      ).to eq({
        suit: 'Spades', tricks: 7
      })
    end

    it "passes with a red hand" do
      create_card(rank: 'Jack', suit: "Diamonds")
      create_card(rank: 'Ace', suit: "Hearts")
      create_card(rank: 10, suit: "Hearts")
      create_card(rank: 9, suit: "Hearts")
      @hand.make_bid

      expect(
        @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
      ).to eq({
        suit: 'Pass', tricks: 0
      })
    end

    it "bids the colour not bid by the opponents" do
      create_card(rank: 'Jack', suit: "Diamonds")
      create_card(rank: 'Ace', suit: "Hearts")
      create_card(rank: 10, suit: "Hearts")
      create_card(rank: 9, suit: "Hearts")
      create_card(rank: 8, suit: "Hearts")
      create_card(rank: 'Jack', suit: "Clubs")
      create_card(rank: 'Ace', suit: "Spades")
      create_card(rank: 10, suit: "Spades")
      create_card(rank: 9, suit: "Spades")
      @hand.make_bid

      expect(
        @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
      ).to eq({
        suit: 'Spades', tricks: 7
      })
    end

    describe "following a bid of 7 hearts" do
      before do
        @hand_two = @game.hands.create!(bid_order: 2)
        @hand_two.bids.create(suit: 'Hearts', tricks: 7)
      end

      it "passes with a black hand" do
        create_card(rank: 'Jack', suit: "Clubs")
        create_card(rank: 'Ace', suit: "Spades")
        create_card(rank: 10, suit: "Spades")
        create_card(rank: 9, suit: "Spades")
        create_card(rank: 'Ace', suit: "Diamonds")
        @hand.make_bid

        expect(
          @hand.bids.last.attributes.symbolize_keys.slice(:suit, :tricks)
        ).to eq({
          suit: 'Pass', tricks: 0
        })
      end
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

  describe "discarding kitty" do
    before do
      @s6  = create_card(rank: 6, suit: "Spades")
      @h10 = create_card(rank: 10, suit: "Hearts")
      @h9  = create_card(rank: 9, suit: "Hearts")
      @h8  = create_card(rank: 8, suit: "Hearts")
    end

    it "discards the lowest three cards" do
      @game.update_attributes(trump_suit: 'Diamonds')
      @hand.cards.where(suit: "Hearts").update_all(is_trump: true)

      @game.set_card_strength

      @hand.reload.choose_kitty

      expect(@hand.cards.reload).to eq([@h10])
    end

    it "does not discard trumps" do
      @game.update_attributes(trump_suit: 'Spades')
      @hand.cards.where(suit: "Spades").update_all(is_trump: true)

      @game.set_card_strength

      @hand.reload.choose_kitty

      expect(@hand.cards.reload).to eq([@s6])
    end
  end

  describe "leading a card" do
    before do
      @game.update_attributes(trump_suit: 'Hearts')

      @game.cards.create!(hand: @game.hands.create!(bid_order: 2), rank: "Jack", suit: "Diamonds", is_trump: true)

      @s4  = create_card(rank: "4", suit: "Spades")
      @h9  = create_card(rank: 10, suit: "Hearts", is_trump: true)
      @h8  = create_card(rank: 8, suit: "Hearts", is_trump: true)
      @ca  = create_card(rank: "Ace", suit: "Clubs")
    end

    it "leads the highest trump if it has it" do
      @jk = create_card(rank: "Joker", suit: nil, is_trump: true)

      @game.set_card_strength

      @hand.lead
      expect(Trick.last.cards_played[0]).to eq(@jk)
    end

    it "leads the lowest trump if it does not have the top" do
      @game.set_card_strength

      @hand.lead
      expect(Trick.last.cards_played[0]).to eq(@h8)
    end

    it "leads the highest of an offsuit if it has one" do
      @h8.destroy

      @game.set_card_strength

      @hand.lead
      expect(Trick.last.cards_played[0]).to eq(@ca)
    end

    it "leads the shortest suit if it has no winners" do
      @game.cards.create!(hand: @game.hands.create!(bid_order: 2), rank: "Ace", suit: "Spades")
      @game.cards.create!(hand: @game.hands.create!(bid_order: 2), rank: "Ace", suit: "Clubs")

      @h8.update_attributes(suit: "Clubs", is_trump: false)
      @ca.update_attributes(rank: "Queen")

      @game.set_card_strength

      @hand.lead
      expect(Trick.last.cards_played[0]).to eq(@s4)
    end
  end

  describe "following" do
    before do
      @game.update_attributes(trump_suit: 'Hearts')
      @hand_two = @game.hands.create!(bid_order: 2)
      @hand_three = @game.hands.create!(bid_order: 3)
      @hand_four = @game.hands.create!(bid_order: 4)

      @game.cards.create!(hand: @hand_two, rank: "Jack", suit: "Diamonds", is_trump: true)

      @ks  = create_card(rank: "King", suit: "Spades")
      @h10  = create_card(rank: 10, suit: "Hearts", is_trump: true)
      @h8  = create_card(rank: 8, suit: "Hearts", is_trump: true)
      @c9 = create_card(rank: 9, suit: "Clubs")
    end

    describe "a hostile lead" do
      before do
        @d8  = create_card(rank: "8", suit: "Diamonds").tap &:lead
      end

      describe "as the first player of your team" do
        before do
          @dk  = create_card(rank: "King", suit: "Diamonds")
        end

        it "plays the highest card of the suit if it has it" do
          @d6  = create_card(hand: @hand_two, rank: 6, suit: "Diamonds")
          @da  = create_card(hand: @hand_two, rank: "Ace", suit: "Diamonds")
          @hand_two.follow

          expect(Trick.last.cards_played.last).to eq(@da)
        end

        it "throws the lowest card if the only winner is a picture card" do
          @d6  = create_card(hand: @hand_two, rank: 6, suit: "Diamonds")
          @dq  = create_card(hand: @hand_two, rank: "Queen", suit: "Diamonds")
          @hand_two.follow

          expect(Trick.last.cards_played.last).to eq(@d6)
        end
      end

      describe "as the second player of your team" do
        before do
          @d4  = create_card(hand: @hand_four, rank: 4, suit: "Diamonds")
          @d10 = create_card(hand: @hand_four, rank: 10, suit: "Diamonds")
          @da  = create_card(hand: @hand_four, rank: "Queen", suit: "Diamonds")
        end

        it "plays the lowest card required to win the trick if the enemy is winning" do
          @d9  = create_card(hand: @hand_three, rank: "9", suit: "Diamonds").tap &:play

          @hand_four.follow

          expect(Trick.last.cards_played.last).to eq(@d10)
        end

        it "throws the lowest card of the suit if the friend is winning the trick" do
          @d9  = create_card(hand: @hand_two, rank: "9", suit: "Diamonds").tap &:play

          @hand_four.follow

          expect(Trick.last.cards_played.last).to eq(@d4)
        end

        it "throws the lowest card of the suit if it can't win" do
          @da  = create_card(hand: @hand_three, rank: "Ace", suit: "Diamonds").tap &:play

          @hand_four.follow

          expect(Trick.last.cards_played.last).to eq(@d4)
        end
      end
    end

    describe "a hostile trump lead" do
      before do
        @dj  = create_card(hand: @hand_four, rank: "Jack", suit: "Hearts", is_trump: true).tap &:lead
      end

      describe "as the first player of your team" do
        it "plays the joker if it has it" do
          @jk  = create_card(hand: @hand, rank: "Joker", suit: nil, is_trump: true)

          @hand.follow

          expect(Trick.last.cards_played.last).to eq(@jk)
        end

        it "throws the lowest card if it doesn't have the winner" do
          @hand.follow

          expect(Trick.last.cards_played.last).to eq(@h8)
        end
      end
    end

    describe "a friendly lead" do
      before do
        @s8 = create_card(rank: "9", suit: "Spades").tap &:lead
      end

      it "plays the highest card of the suit if it has it" do
        @s6  = create_card(hand: @hand_three, rank: 6, suit: "Spades")
        @sa  = create_card(hand: @hand_three, rank: "Ace", suit: "Spades")
        @hand_three.follow

        expect(Trick.last.cards_played.last).to eq(@sa)
      end

      it "plays the highest card of the suit if it's at least two higher than the lead" do
        @s6  = create_card(hand: @hand_three, rank: 6, suit: "Spades")
        @sj  = create_card(hand: @hand_three, rank: "Jack", suit: "Spades")
        @hand_three.follow

        expect(Trick.last.cards_played.last).to eq(@sj)
      end

      it "throws the lowest card if its highest card is the queen or king" do
        @s6  = create_card(hand: @hand_three, rank: 6, suit: "Spades")
        @sj  = create_card(hand: @hand_three, rank: "Queen", suit: "Spades")
        @hand_three.follow

        expect(Trick.last.cards_played.last).to eq(@s6)
      end

      it "throws the lowest card if its highest card is only one higher than the lead" do
        @s6  = create_card(hand: @hand_three, rank: 6, suit: "Spades")
        @sj  = create_card(hand: @hand_three, rank: 10, suit: "Spades")
        @hand_three.follow

        expect(Trick.last.cards_played.last).to eq(@s6)
      end
    end

    describe "when you can't follow suit" do
      before do
      end

      it "trumps if it looks like the other team will win" do
        @d8 = create_card(hand: @hand_two, rank: "8", suit: "Diamonds").tap &:lead
        @hand.follow

        expect(Trick.last.cards_played.last).to eq(@h8)
      end

      it "discards the weakest card if we're winning" do
        @d8 = create_card(hand: @hand_three, rank: "8", suit: "Diamonds").tap &:lead
        @hand.follow

        expect(Trick.last.cards_played.last).to eq(@c9)
      end
    end
  end
end
