class Match < ActiveRecord::Base

  has_many :games
  has_many :match_users
  has_many :users, through: :match_users

  def self.create
    super.tap { |m| m.games.create }
  end

  def join(user)
    self.users << user

    hands = games.first.hands
    [hands[0], hands[2], hands[1], hands[3]].detect do |hand|
      hand.user.nil?
    end.update_attributes(user: user)
  end
end
