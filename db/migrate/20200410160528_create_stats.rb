class CreateStats < ActiveRecord::Migration[5.2]
  def change
    create_table :stats do |t|
      t.integer :turn, null: false
      t.text :raw_stats
      t.timestamps
    end
    add_reference :stats, :games, index: true
  end
end
