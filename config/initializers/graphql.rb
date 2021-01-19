require 'gqli'

class GraphQL
  include Singleton # hate this

  def self.send(query)
    client.execute(query)
  end

  private
  def client
    @client ||= GQLi::Client.new(ENV['DOMS5BE'], validate_query: false)
  end
end
