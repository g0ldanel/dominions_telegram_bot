class Player < ActiveRecord::Base
  has_many :games, through: :player_games
  validates_presence_of :username


end
