class CreatePlayers < ActiveRecord::Migration[6.0]
  def change
    create_table :players do |t|
      t.text :username
    end
    add_reference :player_games, :players, index: true

    #useless ever model/table with just 1 field, more a placeholder for things to come
  end
end
