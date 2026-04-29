# frozen_string_literal: true

module Dnd5e
  module Ingest
    module Parsers
      # Row parsing for ClassTableParser.
      module RowParser
        private

        def process_table(rows, headers)
          rows.map { |r_data| parse_row(r_data, headers) }
        end

        def parse_row(r_data, headers)
          match = r_data[:remainder].split(/\s{2,}/)
          features = match[0].strip

          # Flatten extra values that might have been poorly split
          raw_extra_values = match[1..] || []
          extra_values = raw_extra_values.flat_map { |v| v.match?(/^[—\d\s]+$/) ? v.split : v }

          result = { level: r_data[:level], proficiency_bonus: r_data[:prof], features: features }
          add_slots_if_present(result, extra_values, headers)
          map_extra_values(result, extra_values, headers)
          result
        end

        def map_extra_values(result, values, headers)
          values.each_with_index do |val, i|
            h = headers[i]
            next if slot_header?(h)

            key = (h ? h.downcase.gsub(' ', '_') : "col_#{i + 1}").to_sym
            result[key] = val
          end
        end

        def add_slots_if_present(result, values, headers)
          slots = extract_slots(values, headers)
          result[:slots] = slots if slots
        end
      end
    end
  end
end
