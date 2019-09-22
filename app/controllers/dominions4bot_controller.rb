class Dominions4botController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  # before_action :connect_db
  # before_action :set_character, except: [:inline_keyboard, :keyboard]
  # before_action :set_msg, except: [:set_pg, :callback_query]

  # require 'active_record'
  # require 'sqlite3'
  require 'byebug'
  # context_to_action!

  NUMERICAL_KEYBOARD = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["0"]
      ]
  

  def callback_query(data)
    order = data.split
    send order[0], order[1]
  end


  def status_1024!
    status = ''    

    File.readlines("/tmp/dominions4/1024.log").last(2).each do |line|
      status << line
    end    
    respond_with :message, text: status

  end

  def status_1025!
    status = ''    

    File.readlines("/tmp/dominions4/1025.log").last(2).each do |line|
      status << line
    end    
    respond_with :message, text: status

  end


  # def message(message)
  #   respond_with :message, text: t('.content', text: message['text'])
  # end

  # def inline_query(query, _offset)
  #   query = query.first(10) # it's just an example, don't use large queries.
  #   t_description = t('.description')
  #   t_content = t('.content')
  #   results = Array.new(5) do |i|
  #     {
  #       type: :article,
  #       title: "#{query}-#{i}",
  #       id: "#{query}-#{i}",
  #       description: "#{t_description} #{i}",
  #       input_message_content: {
  #         message_text: "#{t_content} #{i}",
  #       },
  #     }
  #   end
  #   answer_inline_query results
  # end

  # # As there is no chat id in such requests, we can not respond instantly.
  # # So we just save the result_id, and it's available then with `/last_chosen_inline_result`.
  # def chosen_inline_result(result_id, _query)
  #   session[:last_chosen_inline_result] = result_id
  # end

  # def last_chosen_inline_result
  #   result_id = session[:last_chosen_inline_result]
  #   if result_id
  #     respond_with :message, text: t('.selected', result_id: result_id)
  #   else
  #     respond_with :message, text: t('.prompt')
  #   end
  # end

  def action_missing(action, *_args)
    respond_with :message, text: "Eso no se que es" 
  end

  private

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
