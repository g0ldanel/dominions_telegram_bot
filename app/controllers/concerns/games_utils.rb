module GamesUtils
  extend ActiveSupport::Concern
  PORTS = (1024..1029).to_a

  def create_game!(port)
    status = game_status(port).split(', ')
    game = Game.create name: status[0], port: port, era: 'early'
    respond_with :message, text: "Game created:\n#{game.to_s}"
  rescue
    respond_with :message, text: "#{port}: Game not found!"
  end


  def delete_game!(port)
    games = Game.where port: port
    unless games.empty?
      games.destroy_all
      respond_with :message, text: "#{port} has been deleted."
    else
      respond_with :message, text: "#{port}: Game not found!"
    end
  end


  def select_game!
    games = PORTS.map do |port|
      [ {text: "Crear #{port}", callback_data: "create_game! #{port}"},
        {text: "Borrar #{port}", callback_data: "delete_game! #{port}"}]
    end

    respond_with :message, text: "Selecciona:\nBorrar una partida del bot solo hara que deje de leer su estado_", reply_markup: {inline_keyboard:  games}
  end



  private

  def game_status(port)
    lines = File.readlines("/tmp/#{port}.log", chomp: true).last(2)
    lines.first
  end
  def game_players(port)
    lines = File.readlines("/tmp/#{port}.log", chomp: true).last(2)
    lines[1]
  end
end