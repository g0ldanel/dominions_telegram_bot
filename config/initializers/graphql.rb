require 'gqli'

class GraphQL
  include Singleton # hate this

  def self.send(query)
    client.execute(query)
  end

  private
  def self.client
    @client ||= GQLi::Client.new(Rails.application.secrets.graphql[:url],
                                 validate_query: false)
  end
end
