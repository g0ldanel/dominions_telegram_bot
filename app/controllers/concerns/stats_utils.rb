module StatsUtils
  extend ActiveSupport::Concern

  def stats_detail_1028!(section_name)
    respond_with :message, text: "#{section_name} 1028, turno #{parse_turn_nbr}:", text: "#{parse_section(section_name)}", parse_mode: :markdown
  end

  def stats_1028!
    stats = read_titles_1028.map do |title|
      [{text: "#{title}", callback_data: "stats_detail_1028! #{title}"}]
    end

    respond_with :message, text: "Stats disponibles - turno #{parse_turn_nbr}", reply_markup: {inline_keyboard:  stats}
  end

  def parse_turn_nbr
    parse_scores_1028.css('title').text.split(' ').last
  end

  def parse_section(section_name)
    section = read_section_1028 section_index(section_name)
    titles = section.css('tr').first.css('td').map {|td| "|#{td.text}"}
    parsed = section.css('tr').map do |tr|
      "*#{tr.css('td').first.text}* | #{tr.css('td').last.text}\n"
    end
    parsed.join ''
  end

  def section_index(section_name)
    read_titles_1028.index(section_name)
  end

  def read_section_1028(idx)
    parse_scores_1028.css('table')[idx]
  end

  def read_titles_1028
    page = parse_scores_1028
    page.css('h4').map {|title| title.text}
  end

  def parse_scores_1028
    @page = Nokogiri::HTML(open("#{Dir.home}/.dominions5/savedgames/earlytest/scores.html")) if @page.nil?
    @page
  end

end