module Ai
  module Base
    def choose_kitty
      cards.by_strength.last(3).each do |card|
        card.update_attributes!(hand: nil)
      end
    end

    def ai_play
      if game.pending_trick?
        ai_follow
      else
        ai_lead
      end
    end

    def have_highest_trump_in_game
      highest_trump == game.cards.in_play.first
    end

    def have_highest_card_for_trick?(suit)
      # We have the highest unplayed card for the suit
      highest_for_suit(suit).highest_in_suit? &&
      # And it's higher than any card played so far this trick
      winning_card_strength < highest_for_suit(suit).strength
    end

    def winning_card_strength
      game.tricks.last.cards_played.maximum(:strength)
    end

    def first_to_play?
      bid_order == first_hand.bid_order
    end

    def second_to_play?
      [1, -3].include?(bid_order - first_hand.bid_order)
    end

    def third_to_play?
      [2, -2].include?(bid_order - first_hand.bid_order)
    end

    def last_to_play?
      [3, -1].include?(bid_order - first_hand.bid_order)
    end

    def last_with_suit?(suit)
      # Dont let the AI know unless the suit has been played
      previous_trick_cards.for_suit(suit).any? &&
      potential_cards_to_be_played(suit).none?
    end

    def potential_cards_to_be_played(suit)
      # This is cheating - reimplement without cheating
      game.cards.for_suit(suit).in_play.where(hand: hands_yet_to_play)
    end

    def hands_yet_to_play
      game.hands.where.not(id: game.tricks.last.cards.map(&:hand_id) << self.id)
    end

    def cant_follow_suit?(suit)
      !for_suit(suit).in_play.any?
    end

    def cant_trump?(suit)
      no_trumps? || partner_winning? || suit == trump_suit
    end

    def partner_winning?
      game.tricks.last.leading_hand.bid_order % 2 == bid_order % 2
    end

    def no_trumps?
      !cards.trump.in_play.any?
    end

    def previous_trick_cards
      game.cards.played.where('trick_id < ?', game.tricks.last.id)
    end

    def highest_trump
      cards.in_play.first
    end

    def highest_in_game_for_a_suit
      cards.non_trump.in_play.detect { |card| card.highest_in_suit? }
    end

    def highest_for_suit(suit)
      for_suit(suit).in_play.first
    end

    def lowest_trump
      cards.trump.in_play.last
    end
    def lowest_for_suit(suit)
      for_suit(suit).in_play.last
    end

    def lowest_winner(suit)
      for_suit(suit).reverse.detect { |card| card.strength > winning_card_strength }
    end

    def for_suit(suit)
      if suit == trump_suit
        cards.trump.in_play
      else
        cards.non_trump.for_suit(suit).in_play
      end
    end

    def trump_count
      cards.trump.in_play.size
    end

    def shortest_suit
      cards.non_trump.in_play.pluck(:suit).uniq.sort_by do |suit|
        [for_suit(suit).size, for_suit(suit).maximum(:strength)]
      end.first
    end

    def worst_card
      cards.non_trump.in_play.where(suit: shortest_suit).reverse.detect{ |c| c.value <= 10 } ||
      cards.non_trump.in_play.last ||
      cards.in_play.last
    end

    def highest_partner_bid
      game.bids.active.where(hand: partner).last
    end

    def highest_opponent_bid
      game.bids.active.where.not(hand: partner).last
    end

    def first_hand
      game.tricks.last.cards_played.first.hand
    end

    def partner
      game.hands.find_by(bid_order:
        (bid_order + 2) % 4
      )
    end

    def non_bower_count(suit)
      cards.where(suit: suit).where.not(rank: 'Jack').size
    end

    def bower_count(suit)
      cards.where(rank: 'Jack').where("suit = ? or suit = ?", suit, Deck.match(suit)).size
    end

    def left_bower_count(suit)
      cards.where(rank: 'Jack').where("suit = ?", Deck.match(suit)).size
    end

    def right_bower_count(suit)
      cards.where(rank: 'Jack').where("suit = ?", suit).size
    end

    def trump_count_for(suit, rank)
      cards.where(rank: rank).where(suit: suit).size
    end

    def non_trump_ace_count(suit)
      cards.where(rank: 'Ace').where.not(suit: suit).size
    end

    def joker_count
      cards.where(rank: 'Joker').size
    end
  end
end
