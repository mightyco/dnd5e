# frozen_string_literal: true

module Dnd5e
  module Ingest
    module Parsers
      # Table management for ClassTableParser.
      module TableHandler
        private

        def handle_new_class(class_name, state, results)
          save_previous_table(state, results)
          state[:current_class] = class_name
          state[:table_data] = []
          state[:headers] = []
        end

        def handle_table_content(line, state)
          if line.match?(self.class::HEADER_INDICATOR)
            state[:headers] = extract_headers(line)
          elsif (match = line.match(self.class::LEVEL_ROW))
            add_level_row(match, state)
          else
            try_handle_continuation(line, state)
          end
        end

        def add_level_row(match, state)
          state[:table_data] << { level: match[1].to_i, prof: match[2], remainder: match[3] }
        end

        def try_handle_continuation(line, state)
          return unless state[:table_data].any? && line.strip != '' && !line.match?(self.class::CLASS_HEADER)

          handle_feature_continuation(line, state)
        end

        def handle_feature_continuation(line, state)
          return unless line =~ /^\s{10,}/ && !line.match?(/^\s*\d+\s+/)

          last_row = state[:table_data].last
          parts = last_row[:remainder].split(/\s{2,}/)
          parts[0] = "#{parts[0]} #{line.strip}"
          last_row[:remainder] = parts.join('  ')
        end

        def extract_headers(line)
          parts = line.strip.split(/\s{2,}/)
          cf_index = parts.index { |p| p.include?('Class Features') }
          cf_index ? parts[(cf_index + 1)..] : []
        end

        def save_previous_table(state, results)
          return unless state[:current_class] && !state[:table_data].empty?

          results[state[:current_class]] = process_table(state[:table_data], state[:headers])
        end
      end
    end
  end
end
