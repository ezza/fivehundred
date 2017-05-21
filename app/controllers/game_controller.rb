class GameController < ApplicationController
  before_action :authenticate_user!

  before_filter :set_game, except: [:index, :create]

  def index
    @available_games = Game.where(started: false).all.reject { |g| g.hands.any?{ |h| h.user == current_user } }
    @hands = current_user.hands.joins(:game).where("not games.started").all
  end

  def create
    @match = Match.create
    @match.join(current_user)
    redirect_to(@match.games.first)
  end

  def join
    @game.match.join(current_user)
    redirect_to(@game)
  end

  def deal
    @game.deal

    perform_ai_actions_and_redirect
  end

  def show
    @current_trick_cards = Array.new(4) { |i| (@game.current_trick_cards || [])[i] }
    @last_trick_cards = @game.last_trick_cards
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

  def award_game
    redirect_to @game.award_game
  end

  protected

  def set_game
    @game = Game.find params[:id]
  end

  def perform_ai_actions_and_redirect
    10.times do
      @game.perform_ai_action if @game.next_action_ai?
    end unless @game.hands.all? { |hand| hand.user.is_ai? }

    redirect_to @game
  end
end
