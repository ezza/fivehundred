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
    redirect_to(@game)
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

    redirect_to @game
  end

  def award_trick
    @game.award_trick

    redirect_to @game
  end

  def set_game
    @game = Game.find params[:id]
  end
end
