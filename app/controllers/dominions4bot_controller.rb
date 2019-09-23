class Dominions4botController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  require 'byebug'
  
  NUMERICAL_KEYBOARD = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["0"]
      ]
  

  NATIONS = {"Rag" => "Ragha", "Jom" => "Jomon", "Ut" => "Utgard", "Bog" => "Bogarus", "Rl" => "R'lyeh", "Lem" => "Lemuria", "Rap" => "Caelum", "BK" => "C'Tis", "DT" => "T'ien Ch'i"    }




  def callback_query(data)
    order = data.split
    send order[0], order[1]
  end


  def status_1024!
    status = ''    
    lines = File.readlines("/tmp/dominions4/1024.log", chomp: true).last(2)
    status << lines.first
    lines[1].scan(/([A-Z]{1,2}[a-z]{0,}[-+])/).each do |player|
      player_name = player.last[0...-1]
      status << "\n *#{nation_name(player_name)}:* #{player.last.last.last == "+" ? "Turno jugado" : "Pendiente"}"
    end

    respond_with :message, text: status, parse_mode: :Markdown

  end

  def status_1025!
    status = ''    
    lines = File.readlines("/tmp/dominions4/1025.log", chomp: true).last(2)
    status << lines.first
    lines[1].scan(/([A-Z]{1,2}[a-z]{0,}[-+])/).each do |player|
      player_name = player.last[0...-1]
      status << "\n *#{nation_name(player_name)}:* #{player.last.last.last == "+" ? "Turno jugado" : "Pendiente"}"
    end

    respond_with :message, text: status, parse_mode: :Markdown

  end

  
  def action_missing(action, *_args)
    respond_with :message, text: "Eso no se que es" 
  end

  private

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

end
