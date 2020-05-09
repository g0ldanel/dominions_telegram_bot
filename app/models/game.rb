class Game < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :era
  validates :port, numericality: { greater_than: 0, less_than: 25000 }
end
