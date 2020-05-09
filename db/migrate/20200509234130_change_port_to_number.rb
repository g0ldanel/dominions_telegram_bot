class ChangePortToNumber < ActiveRecord::Migration[6.0]
  def change
    change_column :games, :port, :integer
  end
end
