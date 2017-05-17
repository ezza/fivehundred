class HandController < ApplicationController

  def make_bid
    hand.make_bid params[:bid]

    perform_ai_actions_and_redirect
  end

  def play
    hand.play(suit: params[:suit], rank: params[:rank])

    perform_ai_actions_and_redirect
  end

  def discard
    hand.discard(suit: params[:suit], rank: params[:rank])

    perform_ai_actions_and_redirect
  end

  protected

  def hand
    @hand ||= Hand.find params[:hand_id]
  end

  def perform_ai_actions_and_redirect
    10.times do
      hand.game.perform_ai_action if hand.game.reload.next_action_ai?
    end if hand.game.hands.any? { |hand| hand.user }

    redirect_to hand.game
  end

end
