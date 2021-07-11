module DataClient
  module View
    # Do some cleanup on a returned message.
    #
    # TODO: Move to a more sensible place, as this is applicable to any message
    # that will use MarkdownV2 as return format. For now, though, this is only
    # used here.
    def clean(str)
      str.to_s.gsub(/([()~`>#+-=|{}.!\[\].])/, '\\\\\1')
    end

    def from_magic_path_brief(name)
      if name == 'Astral'
        'S'
      else
        name[0]
      end
    end

    def from_nation_brief(n)
      era = case n.era
            when 'EARLY' then 'EA'
            when 'MIDDLE' then 'MA'
            when 'LATE' then 'LA'
            end
      "#{era} #{n.name}"
    end

    def from_magic_school_level(msl)
      return if msl.nil?

      ms = msl.magicSchool.name
      "#{ms} #{msl.level}"
    end

    def from_magic_path_level(mpl)
      return if mpl.level.zero?

      mp = from_magic_path_brief(mpl.magicPath.name)
      "#{mp}#{mpl.level}"
    end

    def from_gem_cost(gc)
      return if gc.nil? || gc.amount.zero?

      n = from_magic_path_brief(gc.magicPath.name)
      "#{n}#{gc.amount}"
    end

    def from_spell(s)
      nations = s.restrictedToNations.map(&method(:from_nation_brief)).join(', ')
      n = (nations.length.nil? || nil) && "Restricted to: #{nations}"
      gem_cost = from_gem_cost(s.gemCost)
      gem_cost_text = "Cost: #{gem_cost}" if gem_cost

      [["*#{s.name}* (_#{s.id}_)",
        from_magic_school_level(s.magicSchoolLevel)].compact.join(', '),
       s.magicPathLevels.map(&method(:from_magic_path_level)).join,

       ["Fatigue: #{s.fatigueCost}",
        "Dam: #{s.damage}",
        "Precision: #{s.precision}",
        gem_cost_text].compact.join(', '),

       n,
       [s.description, s.details && "_Details:_\n#{s.details}"].map do |str|
         str.to_s.split("\n").map(&:strip)
       end.join("\n")].compact.join("\n")
    end
  end
end
