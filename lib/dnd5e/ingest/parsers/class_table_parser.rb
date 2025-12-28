# frozen_string_literal: true

module Dnd5e
  module Ingest
    module Parsers
      # Parses class feature tables from SRD text.
      class ClassTableParser
        CLASS_HEADER = /^\s*([A-Za-z]+)\s+Features\s*$/
        LEVEL_ROW = /^\s*(\d+)\s+([+-]\d+)\s+(.*?)\s*$/

        def parse(content)
          results = {}
          state = { current_class: nil, table_data: [] }

          content.each_line do |line|
            process_line(line, state, results)
          end

          finalize_results(state, results)
          { class_tables: results }
        end

        private

        def process_line(line, state, results)
          if (match = line.match(CLASS_HEADER))
            save_previous_table(state, results)
            state[:current_class] = match[1]
            state[:table_data] = []
          elsif state[:current_class] && line.match?(LEVEL_ROW)
            state[:table_data] << line.strip
          end
        end

        def save_previous_table(state, results)
          return unless state[:current_class] && state[:table_data].size >= 20

          results[state[:current_class]] = process_table(state[:table_data])
        end

        def finalize_results(state, results)
          save_previous_table(state, results)
        end

        def process_table(rows)
          rows.map { |row| parse_row(row) }
        end

        def parse_row(row)
          parts = row.split(/\s{2,}/)
          {
            level: parts[0].to_i,
            proficiency_bonus: parts[1],
            features: parts[2],
            slots: extract_slots(row)
          }
        end

        def extract_slots(row)
          slot_values = row.scan(/(?:\s+)(\d+|—)/).flatten
          return nil if slot_values.size < 9

          slot_values.last(9).map { |v| v == '—' ? 0 : v.to_i }
        end
      end
    end
  end
end
