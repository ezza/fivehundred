module Ai
  module Mimi
    include Base

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
      if cant_follow_suit?(suit) && cant_trump?(suit)
        worst_card
      elsif cant_follow_suit?(suit)
        lowest_trump
      elsif partner_winning? && last_to_play?
        lowest_for_suit(suit)
      elsif last_to_play?
        lowest_winner(suit) || lowest_for_suit(suit)
      elsif have_highest_card_for_trick?(suit)
        highest_for_suit(suit)
      elsif partner_winning?
        lowest_beater(suit) || lowest_for_suit(suit)
      else
        lowest_for_suit(suit)
      end
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
      right_bower_count(suit) * 1.2 +
      left_bower_count(suit) * 1 +
      non_bower_count(suit).to_f * 0.5 +
      trump_count_for(suit, "ace").to_f * 0.3 +
      trump_count_for(suit, "king").to_f * 0.2 +
      trump_count_for(suit, "queen").to_f * 0.1 +
      non_trump_ace_count(suit) * 0.9 +
      cards.where(rank: 'Joker').size * 1.5
    end
  end
end
