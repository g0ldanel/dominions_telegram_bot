module DataClient
  module View
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
      return if gc.nil?
      n = from_magic_path_brief(gc.magicPath.name)
      "#{n}#{gc.amount}"
    end

    def from_spell(s)
      nations = s.restrictedToNations.map(&method(:from_nation_brief)).join(', ')
      n = (nations.length.nil? || nil) && "Restricted to: #{nations}"

      [["*#{s.name}* (_#{s.id}_)",
        from_magic_school_level(s.magicSchoolLevel)].compact.join(", "),
       s.magicPathLevels.map(&method(:from_magic_path_level)).join,
       ["Fat: #{s.fatigueCost}", "Dam: #{s.damage}",
        "Pre: #{s.precision}", from_gem_cost(s.gemCost)].compact.join(", "),
       n,
       [s.description, s.details && "_Details:_\n#{s.details}"].map do |str|
         str.split.map(&:strip)
       end.join("\n")
      ].compact.join("\n")
    end
  end
end
