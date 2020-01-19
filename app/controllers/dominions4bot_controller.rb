class Dominions4botController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  require 'byebug'
  before_action :connect_db
  before_action :set_username
  NUMERICAL_KEYBOARD = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["0"]
      ]


  NATIONS = {"Rag" => "Ragha", "Jom" => "Jomon", "Ut" => "Utgard", "Bog" => "Bogarus", "Rl" => "R'lyeh", "Lem" => "Lemuria", "Rap" => "Caelum", "DT" => "C'Tis", "BK" => "T'ien Ch'i"    }




  def callback_query(data)
    order = data.split
    send order[0], order[1]
  end

  def soy!(player_game)
    arr = player_game.split "@"
    nation = arr.first
    game = arr.last
    pg = PlayerGame.find_or_create_by nation: nation, game: game
    pg.username =  @username
    pg.save!
    respond_with :message, text: "Hola #{@username} eres #{nation} en #{game} "
  end



  def im_playing_in(port)
    players = playing_nations port
    answers = []
    players.each do |player|
      answers << [{text: "Soy #{player}", callback_data: "soy! #{player}@#{port}"}]
    end

    respond_with :message, text: "¿quién eres en #{port}?", reply_markup: {inline_keyboard:  answers}

  end


  def im_playing_in_1024!
    self.im_playing_in 1024
  end

  def im_playing_in_1025!
    self.im_playing_in 1025
  end

  def im_playing_in_1026!
    self.im_playing_in 1026
  end


  def status(port)
    game_status = ''
    lines = File.readlines("/tmp/#{port}.log", chomp: true).last(2)
    game_status << lines.first
    lines[1].scan(/([A-Za-z]{1,2}[a-z]{0,}[-?*+])/).each do |player|
      nation = player.last[0...-1]
      pg = PlayerGame.find_by nation: nation, game: port
      nation_status =  player_status(player.last.last.last)
      unless pg.nil? || nation_status == "Jugado"
        nation += " @#{pg.username}"
      end
      game_status << "\n *#{nation_name(nation)}:* #{nation_status}"
    end

    respond_with :message, text: game_status, parse_mode: :Markdown

  end

  def status_1024!
    self.status 1024
  end

  def status_1025!
    self.status 1025
  end

  def status_1026!
    self.status 1026
  end

  def read_dat_map

  end


  def action_missing(action, *_args)
    respond_with :message, text: "Eso no se que es"
  end



  private

  def playing_nations game
    lines = File.readlines("/tmp/#{game}.log", chomp: true).last(2)
    players = []
    lines[1].scan(/([A-Z]{1,2}[a-z]{0,}[-?*+])/).each do |player| players << player.last[0...-1]
    end
    players
  end

  def connect_db
    unless ActiveRecord::Base.connected?
      ActiveRecord::Base.establish_connection(adapter:  'sqlite3', database: 'db/development.sqlite3')
    end
  end

  def player_status(status)
    case(status)
    when "+"
      "Jugado"
    when "?"
      "A medias"
    when "-"
      "Pendiente"
    when "*"
      "*Conectado*"
    else
      status
    end
  end

  def nation_name(acron)
    NATIONS[acron] || acron
  end

  def connect_db
    unless ActiveRecord::Base.connected?
      ActiveRecord::Base.establish_connection(adapter:  'sqlite3', database: 'db/development.sqlite3')
    end
  end

  def set_msg
    @msg =  update["message"]["from"]["text"] || update["message"]["text"]
    if (@msg =~ /[ ]/).nil? then
      @msg = nil
    else
      @msg = @msg[((@msg =~ /[ ]/) + 1)..@msg.length]
    end

  end

  def is_number? string
    true if Float(string) rescue false
  end

  def set_username
    begin
      @username =  update["message"]["from"]["username"]
    rescue
      @username =  update["callback_query"]["from"]["username"]
    end
  end
end
