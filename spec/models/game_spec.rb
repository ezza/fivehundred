require 'rails_helper'

RSpec.describe Game, type: :model do
  before do
    @game = Game.create
    @game.deal
  end

  describe "deal" do
    it "creates four hands" do
      expect(@game.hands.count).to eq 4
    end

    it "creates gives each hand 10 cards" do
      expect(@game.hands.first.cards.count).to eq 10
    end

    it "leaves three cards for the kitty" do
      expect(@game.cards.where(hand: nil).count).to eq 3
    end
  end

  describe "award bid" do
    before do
      @hand = Hand.create(game: @game)
      3.times do
        @hand.bids.create(suit: "Pass")
      end
      @hand.bids.create(suit: 'Hearts')
      @game.award_bid
    end

    it "assigns the kitty to the winning player" do
      expect(@game.cards.where(hand: nil).count).to eq 3
    end

    it "sets the trump suit to the winning bid" do
      expect(@game.trump_suit).to eq "Hearts"
    end

    it "marks the ace of hearts trumps" do
      expect(@game.cards.find_by(rank: 'Ace', suit: 'Hearts').is_trump).to be true
    end

    it "marks the jack of diamonds trumps" do
      expect(@game.cards.find_by(rank: 'Jack', suit: 'Diamonds').is_trump).to be true
    end

    it "marks the joker trumps" do
      expect(@game.cards.find_by(rank: 'Joker').is_trump).to be true
    end

    it "marks the correct number of cards as trumps" do
      expect(@game.cards.where(is_trump: true).count).to eq(13)
    end
  end
end
