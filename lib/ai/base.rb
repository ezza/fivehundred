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
      highest_for_suit(suit).highest_in_suit? &&
      winning_card_strength < highest_for_suit(suit).strength
    end

    def winning_card_strength
      game.tricks.last.cards_played.maximum(:strength)
    end

    def last_to_play?
      [3, -1].include?(bid_order - game.tricks.last.cards_played.first.hand.bid_order)
    end

    def cant_follow_suit?(suit)
      !for_suit(suit).any?
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

    def lowest_beater(suit)
      for_suit(suit).where("strength > ?", winning_card_strength.floor + 2)
        .where("strength < 12")
        .last
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
      cards.non_trump.in_play.where(suit: shortest_suit).last || cards.in_play.last
    end

    def highest_partner_bid
      game.bids.active.where(hand: partner).last
    end

    def highest_opponent_bid
      game.bids.active.where.not(hand: partner).last
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
  end
end