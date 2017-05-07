class Card < ActiveRecord::Base
  belongs_to :hand

  def value
    case rank
    when 'Ace'
      14
    when 'King'
      13
    when 'Queen'
      12
    when 'Jack'
      11
    else
      rank
    end
  end

  def to_s
    "#{rank} of #{suit}"
  end
end
