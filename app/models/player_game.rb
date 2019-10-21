class PlayerGame < ActiveRecord::Base
  validates_presence_of :username
  validates_presence_of :game
end
