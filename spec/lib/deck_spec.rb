require 'rails_helper'

RSpec.describe Deck do
  it "has 43 cards" do
    expect(Deck.cards.count).to eq 43
  end

  it "has 10 clubs" do
    expect(Deck.cards.select{ |c| c[:suit] == 'Clubs' }.count).to eq 10
  end

  it "has 11 diamonds" do
    expect(Deck.cards.select{ |c| c[:suit] == 'Hearts' }.count).to eq 11
  end

  it "has 1 Joker" do
    expect(Deck.cards.select{ |c| c[:rank] == 'Joker' }.count).to eq 1
  end

  it "has 2 fours" do
    expect(Deck.cards.select{ |c| c[:rank] == 4 }.count).to eq 2
  end

  it "has 4 tens" do
    expect(Deck.cards.select{ |c| c[:rank] == 10 }.count).to eq 4
  end
end
