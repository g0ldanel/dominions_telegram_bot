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
      "" unless msl
      ms = msl.magicSchool.name
      "#{ms} #{msl.level}"
    end

    def from_magic_path_level(mpl)
      "" unless mpl.level > 0
      mp = from_magic_path_brief(msl.magicPath.name)
      "#{mp}#{mpl.level}"
    end

    def from_spell(s)
      nations = s.restrictedToNations.map(method(:from_nation_brief)).join(', ')
      n = (nations.length.nil? || nil) && "Restricted to: #{nations}"

      ["**#{s.name}** (*#{s.id}*), #{fromMagicSchoollevel(s.magicSchoollevel)}",
       s.magicPathLevels.map(method(:from_magic_path_level)).join,
       n,
       "*#{s.description}*",
      ].join('\n')
    end
  end
end
