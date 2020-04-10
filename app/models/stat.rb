class Stat < ActiveRecord::Base
  belongs_to :game
  validates_presence_of :turn
end
