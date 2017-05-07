require 'rails_helper'

RSpec.describe Game, type: :model do
  describe "deal" do
    before do
      @game = Game.create
      @game.deal
    end

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
end
