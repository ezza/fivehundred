class HandController < ApplicationController

  def make_bid
    hand.make_bid params[:bid]

    redirect_to(hand.game)
  end

  def play
    hand.play

    redirect_to(hand.game)
  end

  protected

  def hand
    @hand ||= Hand.find params[:hand_id]
  end

end
