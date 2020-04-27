# coding: utf-8
class Dominions4botController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include StatsUtils
  require 'byebug'
  before_action :connect_db
  before_action :set_username
  NUMERICAL_KEYBOARD = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["0"]
      ]


  NATIONS = {"Rag" => "Ragha", "Jom" => "Jomon", "Ut" => "Utgard", "Bog" => "Bogarus", "Rl" => "R'lyeh", "Lem" => "Lemuria", "Rap" => "Caelum", "DT" => "C'Tis", "BK" => "T'ien Ch'i" }




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


  PORTS = (1024..1030).to_a

  PORTS.each do |i|
    define_method("im_playing_in_#{i}!") do
      self.public_send("im_playing_in", i)
    end

    define_method("status_#{i}!") do
      self.public_send("status", i)
    end
  end


  def status(port)
    matrix, description = get_full_status_for(port)
    player_info = matrix.map do |player, (pg, status)|
      player_name = if status == :played
                      ""
                    else
                      " @#{player}"
                    end
      " *#{nation_name(pg.nation)}#{player_name}:* #{status_name(status)}"
    end

    respond_with :message, text: [description, player_info].join("\n "), parse_mode: :Markdown
  end

  def status_for_player_everywhere(player)
    status_per_port = PORTS.map do |p|
      status_info, _ = get_full_status_for(p)
      status = status_info[player]&.last
      [p, status] if status
    end.compact

    text = ["#{player}, está jugando en las siguientes partidas:",
            "En #{p} está #{status}"
           ].join("\n ")
    respond_with :message, text: text, parse_mode: :Markdown
  end

  def read_dat_map

  end


  def action_missing(action, *_args)
    respond_with :message, text: "Eso no se que es"
  end

  def scores_1028!
    respond_with :message, text: read_scores_file_1028, parse_mode: "html"
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
       :played
     when "?"
       :unfinished
     when "-"
       :pending
     when "*"
       :connected
     else
       status
     end
   end

   def status_name(status)
     case(status)
     when :played
       "Jugado"
     when :unfinished
       "A medias"
     when :pending
       "Pendiente"
     when :connected
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

   def get_full_status_for(port)
     # returns a hash {player: [pg, status]} and a description of the game
     status_grid = {}
     lines = File.readlines("/tmp/#{port}.log", chomp: true).last(2)
     lines[1].scan(/([A-Za-z]{1,2}[a-z]{0,}[-?*+])/).each do |player|
       nation = player.last[0...-1]
       pg = PlayerGame.find_by nation: nation, game: port
       nation_status =  player_status(player.last.last.last)
       status_grid[pg.username] = [pg, nation_status] unless pg.nil?
     end
     [status_grid, lines.first]
   end
end
