# frozen_string_literal: true

module Dnd5e
  module Ingest
    module Parsers
      # Parses class feature tables from SRD text.
      class ClassTableParser
        CLASS_HEADER = /^\s*([A-Za-z]+)\s+Features\s*$/
        LEVEL_ROW = /^\s*(\d+)\s+([+-]\d+)\s+(.*)$/
        # A more generic header detector that looks for the core columns
        HEADER_INDICATOR = /^\s*Level\s+Proﬁciency\s+Bonus\s+Class\s+Features/

        def parse(content)
          results = {}
          state = { current_class: nil, table_data: [], headers: [] }

          content.each_line do |line|
            process_line(line, state, results)
          end

          finalize_results(state, results)
          { class_tables: results }
        end

        private

        def process_line(line, state, results)
          if (match = line.match(CLASS_HEADER))
            handle_new_class(match[1], state, results)
          elsif state[:current_class]
            handle_table_content(line, state)
          end
        end

        def handle_new_class(class_name, state, results)
          save_previous_table(state, results)
          state[:current_class] = class_name
          state[:table_data] = []
          state[:headers] = []
        end

        def handle_table_content(line, state)
          if line.match?(HEADER_INDICATOR)
            state[:headers] = extract_headers(line)
          elsif (match = line.match(LEVEL_ROW))
            state[:table_data] << { row: line.strip, level: match[1].to_i, prof: match[2], remainder: match[3] }
          end
        end

        def extract_headers(line)
          parts = line.strip.split(/\s{2,}/)
          parts.size > 3 ? parts[3..] : []
        end

        def save_previous_table(state, results)
          return unless state[:current_class] && !state[:table_data].empty?

          results[state[:current_class]] = process_table(state[:table_data], state[:headers])
        end

        def finalize_results(state, results)
          save_previous_table(state, results)
        end

        def process_table(rows, headers)
          rows.map { |r_data| parse_row(r_data, headers) }
        end

        def parse_row(r_data, headers)
          match = r_data[:remainder].split(/\s{2,}/)
          features = match[0]
          extra_values = match[1..] || []

          result = { level: r_data[:level], proficiency_bonus: r_data[:prof], features: features }
          map_extra_values(result, extra_values, headers)
          add_slots_if_present(result, r_data[:row])
          result
        end

        def map_extra_values(result, values, headers)
          values.each_with_index do |val, i|
            key = (headers[i] ? headers[i].downcase.gsub(' ', '_') : "col_#{i + 1}").to_sym
            result[key] = val
          end
        end

        def add_slots_if_present(result, row)
          slots = extract_slots(row)
          result[:slots] = slots if slots
        end

        def extract_slots(row)
          slot_values = row.scan(/(?:\s+)(\d+|—)/).flatten
          # Spell slot tables usually have 9 columns of slots at the end.
          # If we have 9 or more values that look like slots, take the last 9.
          return nil if slot_values.size < 9

          slot_values.last(9).map { |v| v == '—' ? 0 : v.to_i }
        end
      end
    end
  end
end
