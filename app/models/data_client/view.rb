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

    def from_spell(s)
      nations = s.restrictedToNations.map(&method(:from_nation_brief)).join(', ')
      n = (nations.length.nil? || nil) && "Restricted to: #{nations}"

      [["*#{s.name}* (_#{s.id}_)",
        from_magic_school_level(s.magicSchoolLevel)].compact.join(", "),
       s.magicPathLevels.map(&method(:from_magic_path_level)).join,
       n,
       s.description.strip.split.map{|l| "_#{l.strip}_" }.join("\n"),
      ].compact.join("\n")
    end
  end
end
