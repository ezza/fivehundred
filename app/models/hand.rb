class Hand < ActiveRecord::Base
  belongs_to :game
  has_many :cards
end
