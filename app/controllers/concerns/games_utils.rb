module GamesUtils
  extend ActiveSupport::Concern
  PORTS = (1024..1029).to_a


  def select_game!
    games = PORTS.map do |port|
      if Game.exists? port: port
        [{text: "Borrar #{port}", callback_data: "delete_game! #{port}"},{text: "Who is who in #{port}?", callback_data: "who_is_who #{port}" }]
      else
        [{text: "Who is who in #{port}?", callback_data: "who_is_who #{port}" },{text: "Crear #{port}", callback_data: "create_game! #{port}"},]
      end
    end

    respond_with :message, text: "Selecciona:\n _Borrar una partida del bot solo hara que deje de leer su estado_", reply_markup: {inline_keyboard:  games}, parse_mode: :Markdown
  end


  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #--- who is who

  def who_is_who(port)
    game = Game.find_by port: port
    unless game.nil?
      answer = game.player_games.map do |pg|
        " - *#{nation_name(pg.nation)}:* #{pg.player.username}\n"
      end.flatten.join ''
      respond_with :message, text: "#{port}:\n#{answer}", parse_mode: :Markdown
    else
      respond_with :message, text: "Payo, no veo a nadie para esa partida (#{port})", parse_mode: :Markdown
    end
  end


  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #--- handle Games

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