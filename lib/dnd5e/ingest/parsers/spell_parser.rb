# frozen_string_literal: true

require_relative '../../core/spell'

module Dnd5e
  module Ingest
    module Parsers
      # Parses spells from text.
      class SpellParser
        # Regex to identify the start of a spell block based on standard headers.
        SPELL_BLOCK_REGEX = /
          ^(?<name>[A-Z][a-zA-Z\s']+)$
          \s+
          (?<level_school>(?:(?:\d+\w{2}-level|Cantrip).*?))
          \s+
          Casting\sTime:\s*(?<time>[^\n]+)
          \s+
          Range:\s*(?<range>[^\n]+)
          \s+
          Components:\s*(?<components>[^\n]+)
          \s+
          Duration:\s*(?<duration>[^\n]+)
          \s+
          (?<description>.*?)
          (?=^[A-Z][a-zA-Z\s']+$|\Z)
        /xmsu

        def parse(content)
          spells = []
          content = prepare_content(content)

          cursor = 0
          while (match_data = SPELL_BLOCK_REGEX.match(content, cursor))
            spells << build_spell(match_data)
            cursor = match_data.end(:description)
          end

          { spells: spells }
        end

        private

        def prepare_content(content)
          content.gsub(/\r\n?/, "\n").force_encoding('UTF-8')
        end

        def build_spell(match_data)
          level, school = parse_level_school(match_data[:level_school].strip)

          attributes = {
            name: match_data[:name].strip, level: level, school: school,
            casting_time: match_data[:time].strip, range: match_data[:range].strip,
            components: match_data[:components].strip, duration: match_data[:duration].strip,
            description: match_data[:description].strip
          }
          Dnd5e::Core::Spell.new(**attributes)
        end

        def parse_level_school(text)
          parts = text.split(' ', 2)
          [parts[0], parts[1]]
        end
      end
    end
  end
end
