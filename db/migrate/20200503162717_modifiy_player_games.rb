class ModifiyPlayerGames < ActiveRecord::Migration[6.0]
  def change
    remove_column :player_games, :username
    remove_column :player_games, :game
    add_reference :player_games, :game, index: true
  end
end
