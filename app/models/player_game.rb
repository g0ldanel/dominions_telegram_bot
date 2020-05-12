class PlayerGame < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  validates_presence_of :nation
  delegate :name, :port, to: :game, prefix: :gm

end
