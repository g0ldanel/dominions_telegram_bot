class CreateGame < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.string :name, null: false
      t.integer :current_turn, default: 1
      t.string :era


      t.timestamps
    end
  end
end
