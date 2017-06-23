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
    @last_trick_cards = @game.last_trick_cards.to_a
    @hands = @game.hands.all.to_a
    
    loops = 0
    while @hands.first.user != current_user
      @hands.rotate!
      loops += 1
      break if loops > 4
    end

    loops = 0
    while @last_trick_cards.first.hand.user != current_user
      @last_trick_cards.rotate!
      loops += 1
      break if loops > 4
    end unless @last_trick_cards.empty?

    @cards = @hands.map {|h| @game.current_trick_cards.detect { |c| c.hand == h } }

    @bids = @game.bids.last(4).to_a

    unless @game.bids.where(hand: @hands.first).any?
      4 - @bids.count.times {|i| @bids.unshift(nil) }
    end
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
