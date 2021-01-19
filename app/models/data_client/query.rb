require 'gqli'

module DataClient
  module Query
    class << self
      def spells(n)
        GQLi::DSL.query {
          spells(name: n) {
            id
            name
            description
            magicSchoolLevel {
              magicSchool {
                name
              }
              level
            }
            magicPathLevels {
              magicPath {
                name
              }
              level
            }
            restrictedToNations {
              name
              era
            }
          }
        }
      end
    end
  end
end
