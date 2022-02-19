# coding: utf-8
require 'graphql'

class Dominions4botController < Telegram::Bot::UpdatesController
  include ::DataClient::View

  #rescue_from Exception, :with => :log_error
  EXCUSES = [ "A mi que me cuentas, diselo a Pedro que fijo que es culpa suya",
              "Yo que sé, ataca a Dani",
              "No dejes que Tien Chi llegue al late game",
              "Recuerda, un Panda siempre paga sus deudas",
              "No le hagas caso",
              "Creo que te voy a ignorar eso que has dicho",
              "¿Te has tomado la pastilla del TOC hoy?"]
  PORTS = (1024..1029).to_a
  include Telegram::Bot::UpdatesController::MessageContext
  include StatsUtils
  include GamesUtils
  require 'byebug'

  before_action :connect_db
  before_action :set_username
  before_action :set_player

  NUMERICAL_KEYBOARD = [
    ["1", "2", "3"],
    ["4", "5", "6"],
    ["7", "8", "9"],
    ["0"]
  ]
  NATIONS = {"Rag" => "Ragha", "Jom" => "Jomon", "Ut" => "Utgard", "Bog" => "Bogarus", "Rl" => "R'lyeh", "Lem" => "Lemuria", "Rap" => "Caelum", "DT" => "C'Tis", "BK" => "T'ien Ch'i"    }

  PORTS.each do |i|
    define_method("im_playing_in_#{i}!") do
      respond_with :message, text: "¿quién eres en #{i}?", reply_markup: {inline_keyboard:  im_playing_in(i)}
    end

    define_method("status_#{i}!") do
      respond_with :message, text: "Status #{i}:\n #{status(i)}", parse_mode: :Markdown
    end
  end

  def comova!
      respond_with :message, text: "Status #{"2042"}:\n #{status("2042")}\n\nABUELO, ESTA ES 2043:\n#{status('2043')}", parse_mode: :Markdown
  end

  def botonaso!(port)
    if @username != 'g0ldan'
      respond_with :message, text: "Uy, uy, uy. No toques las cosas de los mayores, y diselo a @g0ldan!\n", parse_mode: :Markdown
    else
      game = Game.find_by port: port
      system "echo setinterval 2160 > ~/.dominions5/savedgames/#{game.name}/domcmd"
      respond_with :message, text: "Ea, ya. Siempre esperando por el mismo.\n\n#{EXCUSES.sample}", parse_mode: :Markdown
    end
  end

  def reinicia!(port)
    if @username != 'g0ldan'
      respond_with :message, text: "Uy, uy, uy. No toques las cosas de los mayores, y diselo a @g0ldan!\n", parse_mode: :Markdown
    else
      game = Game.find_by port: port
      system "ps ax |grep #{port} | awk '{print $1}' | xargs kill -9"
      system "sh /var/projects/dominions_scripts/#{port}.sh &"
      respond_with :message, text: "Ea, ya. Siempre esperando por el mismo.\n\n#{EXCUSES.sample}", parse_mode: :Markdown
    end
  end


  def dalealotro!
    system "echo settimeleft 10 > ~/.dominions5/savedgames/bootcamp_early3BIS/domcmd"
    respond_with :message, text: "Ya voy, ya voy! 10 segundos para host\n", parse_mode: :Markdown
    (1..10).each do |i|
      respond_with :message, text: "#{i}\n", parse_mode: :Markdown
    end
    respond_with :message, text: "host 43, reclutas!"
  end



  def daleahi!
    system "echo settimeleft 10 > ~/.dominions5/savedgames/bootcamp_early3/domcmd"
    respond_with :message, text: "Ya voy, ya voy! 10 segundos para host\n", parse_mode: :Markdown
    (1..10).each do |i|
      respond_with :message, text: "#{i}\n", parse_mode: :Markdown
    end
    respond_with :message, text: "host 42, reclutas!"
  end

  def callback_query(data)
    order = data.split
    begin
      send order[0], order[1]
    rescue
      send order[0]
    end
  end

  def soy!(player_game)
    arr = player_game.split "__"
    nation = arr.first
    port = arr.last
    game = Game.find_by port: port
    pg = PlayerGame.find_or_create_by player: @player, game: game
    pg.nation =  nation
    pg.save!
    respond_with :message, text: "Hola #{@username} eres #{nation} en #{port} "
  end



  #tells the player in which games she/he has pending turns
  def need_drugs!
    pgs = PlayerGame.where player: @player

    drugs = pgs.map { |p| ["#{p.gm_port}: #{find_nation_status(p.gm_port,p.nation)}"] }.flatten.join "\n"

    respond_with :message, text: "Hola #{@username}, tus dronjas:\n#{drugs}"
  end

  def im_playing_in(port)
    players = playing_nations port

    answers = players.map do |player|
      [{text: "Soy #{player[0...-1]}", callback_data: "soy! #{player[0...-1]}__#{port}"}]
    end

    respond_with :message, text: "¿quién eres en #{port}?", reply_markup: {inline_keyboard:  answers}
  end

  def status!
    games = Game.all
    options = games.map do |game|
      [{text: "#{game.port} game - #{game.name}", callback_data: "status_#{game.port}!"}]
    end
    respond_with :message, text: "Available games:", reply_markup: {inline_keyboard:  options}
  end

  #new
  def status(port)
    game_status = "Hola #{@username}:\n"
    lines = File.readlines("/tmp/#{port}.log", chomp: true).last(2)
    return lines.last if lines.join(' ').include? 'Setup' # if server is not in turns mode, just give back info available
    game_status << lines.first
    game_status.gsub! '_',''
    lines[1].scan(/([A-Za-z]{1,2}[a-z]{0,2}[-?*+])/).each do |nation_line|
      nation = nation_line.last[0...-1]

      pgs = PlayerGame.joins(:game).where nation: nation, "games.port" => port
      nation_status =  player_status(nation_line.last.last.last)
      if (!pgs.empty? && nation_status != "Jugado")
        nation += " @#{pgs.first.player.username}"
      end
      game_status << "\n *#{nation_name(nation)}:* #{nation_status}"
    end

    game_status +="\n\n #{whos_guilty(game_status.scan(/(@[A-Za-z0-9]{1,20})/).first.first)} "if game_status.count('@') == 1
    game_status
  rescue => e
    Logger.new(STDOUT).error "Ups! Doing status #{port} got: #{e.message}"
  end



  def action_missing(action, *_args)
    action_text = _args[0]['text'].split('@')[0][0..]
    Logger.new(STDOUT).info "action text: #action_text"
    if action_text[0] == '/'
      action_text += '!'
      send action_text[1..]
    else

      respond_with :message, text: EXCUSES.sample
    end
  rescue
    respond_with :message, text: "Eso no se que es"
  end

  def scores_1028!
    respond_with :message, text: read_scores_file_1028, parse_mode: "html"
  end

  INSPECTOR_TABS = {
    item: %w{item i objeto},
    spell: %w{spell s hechizo},
    unit: %w{unit u unidad},
    site: %w{site s lugar},
    merc: %w{merc m mercenaries mercenary mercenario mercenarios},
    event: %w{event e eventos}
  }
  # we're flexible with the search areas used
  SEARCH_TERMS = INSPECTOR_TABS.map do |k, vs|
    vs.map { |v| [v, k.to_s] }
  end.flatten(1).to_h

  DEFAULT_TERMS = INSPECTOR_TABS.map {|_, vs| vs.first }

  def busca!(*search_terms)
    sent_area = search_terms.shift if search_terms.length > 1
    area = SEARCH_TERMS[sent_area] if sent_area

    if area.nil?
      respond_with :message, text: "Puedes buscar por #{DEFAULT_TERMS.join(', ')};\nPorfi incluye términos de búsqueda :)"
    else
      search = search_terms.join(' ')
      inspector_args = { page: area, "#{area}q": search }
      server_results =
        case area
        when 'spell'
          s = GraphQL.send(DataClient::Query.spells(search)).data.spells
          s.map(&method(:from_spell)).join("\n\n")
        end

      link = "https://larzm42.github.io/dom5inspector/?#{inspector_args.to_query}"

      message = [clean(link),
                 clean(server_results)].compact.join("\n\n")
      respond_with :message, text: message, parse_mode: :MarkdownV2
    end
  end

  private

  def whos_guilty(player_name)
logger.info "\n\n\n\n\n\n #{player_name}\n\n\n\n\n\n"
    case player_name
    when '@blulaktuko'
      'En Alemania no pasaban estas cosas con el Caudillo'
    when '@ClubbingSealCub'
      'No te lo pienses tanto, si total, sabes que es pique de maquina'
    when '@Tr0b1n'
      'Que alguien despierte al Abuelo que se la ha pasado el turno(otra vez)!'
    when '@R7K7B'
      'De quien es la culpa de que no haya turnooooo...???'
    when '@g0ldan'
      'Amo, amo! Se bueno con ellos! No se lo merecen, pero muestrales tu misericordia!'
    else
      "La gente necesita dronjas #{player_name}"
    end
  end

  def find_nation_status(port, nation)
    nations = playing_nations port
    idx = nations.index {|current| current.start_with? nation}
    player_status(nations[idx][-1])
  end

  def playing_nations port
    lines = File.readlines("/tmp/#{port}.log", chomp: true).last(2)
    lines[1].scan(/([A-Z]{1,2}[a-z]{0,}[-?*+])/).map {|player| player.last }
  end

  def connect_db
    unless ActiveRecord::Base.connected?
      ActiveRecord::Base.establish_connection(adapter:  'sqlite3', database: 'db/development.sqlite3')
    end
  end

  def player_status(raw_status)
   #TODO make an enum with this
   case(raw_status)
   when "+"
     "Jugado"
   when "?"
     "A medias"
   when "-"
     "Pendiente"
   when "*"
     "*Conectado*"
   else
     raw_status
   end
  end

  def nation_name(acron)
   NATIONS[acron] || acron
  end

  def game_name(line)
    line[0,line.index(',')]
  end

  def connect_db
   unless ActiveRecord::Base.connected?
     ActiveRecord::Base.establish_connection(adapter:  'sqlite3', database: 'db/development.sqlite3')
   end
  end

  def set_msg
   raw_msg =  update["message"]["from"]["text"] || update["message"]["text"]

   @msg = if (raw_msg=~ /[ ]/).nil? then
     nil
   else
     raw_msg[((raw_msg =~ /[ ]/) + 1)..raw_msg.length]
   end
  end

  def is_number? string
   true if Float(string) rescue false
  end

  def set_username
    @username =  update["message"]["from"]["username"]
  rescue
    @username = update["callback_query"]['from']['username']
  end

  def set_player
    @player = Player.find_or_create_by username: @username
  end

  def log_error(e)
    Logger.new(STDOUT).error "\n********************\nUps! Exception raised, got: #{e.message}\n********************\n"
    respond_with :message, text: "Ups!\n\n```#{e.message}```\nNada que ver, circulen...", parse_mode: :Markdown
  end
end
