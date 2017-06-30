module Ai
  module Mimi
    include Base

    def ai_bid
      strongest = strongest_suit
      strength = strength(strongest_suit)

      bid = bids.new(suit: strongest, tricks: 6)
      until bid.score > game.highest_bid.try(:score).to_i
        bid.tricks += 1
        strength -= 1.5
      end

      unless strength > 2
        bid.suit, bid.tricks = 'Pass', 0
      end

      bid
    end

    def ai_lead
      if have_highest_trump_in_game
        highest_trump
      elsif trump_count > 1
        cards.trump.in_play.last
      elsif highest_in_game_for_a_suit
        highest_in_game_for_a_suit
      else
        worst_card
      end
    end

    def ai_follow(suit = game.tricks.last.suit_lead)
      if cant_follow_suit?(suit)
        play_offsuit(suit)
      elsif last_to_play?
        play_as_last(suit)
      elsif should_play_high?(suit)
        highest_for_suit(suit)
      else
        lowest_for_suit(suit)
      end
    end

    def should_play_high?(suit)
      have_highest_card_for_trick?(suit) ||
      (third_to_play? && partner_played_low?)
    end

    def play_offsuit(suit)
      if partner_winning? || cant_trump?(suit)
        worst_card
      else
        lowest_trump
      end
    end

    def play_as_last(suit)
      winner = lowest_winner(suit) if !partner_winning?
      winner || lowest_for_suit(suit)
    end

    def strongest_suit
      Deck::SUITS.sort_by do |suit|
        strength(suit)
      end.last
    end

    def strength(suit)
      score = internal_strength(suit)

      score += 1.3 if highest_partner_bid.try(:suit) == suit
      score += 0.3 if highest_partner_bid.try(:suit) == Deck.match(suit)
      score -= 1.3 if highest_opponent_bid.try(:suit) == suit
      score -= 0.3 if highest_opponent_bid.try(:suit) == Deck.match(suit)

      score
    end

    def internal_strength(suit)
      joker_count * 1.5 +
      right_bower_count(suit) * 1.2 +
      left_bower_count(suit) * 1 +
      non_bower_count(suit).to_f * 0.5 +
      trump_count_for(suit, "ace").to_f * 0.3 +
      trump_count_for(suit, "king").to_f * 0.2 +
      trump_count_for(suit, "queen").to_f * 0.1 +
      non_trump_ace_count(suit) * 0.9
    end

    def partner_played_low?
      game.tricks.last.cards_played.find_by(hand: partner).value <= 10
    end
  end
end
