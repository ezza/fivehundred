class GameController < ApplicationController
  before_action :authenticate_user!

  before_filter :set_game, except: [:index, :create]

  def index
    @available_games = Game.where(started: false).all.reject { |g| g.hands.any?{ |h| h.user == current_user } }
    @hands = current_user.hands.joins(:game).where("not games.started").all
  end

  def create
    @game = Game.create
    @game.join(current_user)
    redirect_to(@game)
  end

  def deal
    @game.deal

    perform_ai_actions_and_redirect
  end

  def join
    @game.join(current_user)
    redirect_to(@game)
  end

  def show
    @current_trick_cards = Array.new(4) { |i| (@game.current_trick_cards || [])[i] }
    @player_hand = @game.hands.where(user: current_user).first
  end

  def award_bid
    @game.award_bid

    perform_ai_actions_and_redirect
  end

  def award_trick
    @game.award_trick

    perform_ai_actions_and_redirect
  end

  protected

  def set_game
    @game = Game.find params[:id]
  end

  def perform_ai_actions_and_redirect
    10.times do
      @game.perform_ai_action if @game.next_action_ai?
    end if @game.hands.any? { |hand| hand.user }

    redirect_to @game
  end
end
