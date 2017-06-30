class HandController < ApplicationController

  def make_bid
    hand.make_bid params[:bid]

    perform_ai_actions_and_redirect
  end

  def play
    card = Card.find_by(id: params[:id])

    if card && !card.trick_id?
      if card.game.pending_trick?
        card.play
      else
        card.lead
      end
    end

    perform_ai_actions_and_redirect
  end

  def discard
    Card.find(params[:id]).each do |card|
      card.update_attributes!(hand: nil)
    end if params[:id].is_a?(Array) && params[:id].length == 3

    perform_ai_actions_and_redirect
  end

  protected

  def hand
    @hand ||= Hand.find params[:hand_id]
  end

  def perform_ai_actions_and_redirect
    10.times do
      hand.game.perform_ai_action if hand.game.reload.next_action_ai?
    end unless hand.game.hands.all? { |hand| hand.user.is_ai? }

    redirect_to hand.game
  end

end
