class CreatePlayerGames < ActiveRecord::Migration[5.2]
  def change
    create_table :player_games do |t|
    	t.integer :game, null: false
    	t.string :username, null: false
    	t.string :nation, null: false

    	t.timestamps
    end
  end
end
