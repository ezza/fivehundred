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

    def choose_kitty
      3.times { |i| worst_card.update_attributes!(hand: nil) }
    end

    def ai_lead
      if have_highest_trump_in_game && number_of_opponents_with_potential_trumps > 0
        highest_trump
      elsif trump_count > 1 && number_of_opponents_with_potential_trumps > 1
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
      elsif last_to_play? || last_with_suit?(suit)
        play_as_last(suit)
      elsif should_play_high?(suit)
        highest_for_suit(suit)
      else
        lowest_for_suit(suit)
      end
    end

    def should_play_high?(suit)
      # !partner winning and some other stuff
      !partner_should_win_trick?(suit) &&
      partner_played_low? || have_highest_card_for_trick?(suit)
    end

    def play_offsuit(suit)
      if partner_winning? || cant_trump?(suit)
        worst_card
      else
        lowest_winner(trump_suit) || worst_card
      end
    end

    def play_as_last(suit)
      winner = lowest_winner(suit) if !partner_should_win_trick?(suit)
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
      partner_card = game.tricks.last.cards_played.find_by(hand: partner)
      partner_card && partner_card.value <= 10
    end

    def partner_should_win_trick?(suit)
      partner_winning? &&
      potential_cards_to_be_played(suit).where("strength > ?", winning_card_strength).none?
    end

    def number_of_opponents_with_potential_trumps
      return 2 unless tricks_where_trumps_led.any?

      2 - (tricks_where_trumps_led.map { |trick|
        trick.cards.where(is_trump: false).map(&:hand)
      }.flatten.uniq - [self, partner]).count
    end

    def most_throwable_suit
      suits_by_card_count.detect do |suit|
        for_suit(suit).size + for_suit(suit).maximum(:strength) < 14
      end || suits_by_card_count.detect do |suit|
        for_suit(suit).size + for_suit(suit).maximum(:strength) < 15
      end
    end

    def worst_card
      if most_throwable_suit
        cards.in_play.where(suit: most_throwable_suit).last
      else
        cards.in_play.last
      end
    end
  end
end
