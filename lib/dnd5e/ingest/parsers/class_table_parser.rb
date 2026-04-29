# frozen_string_literal: true

require_relative 'table_handler'
require_relative 'row_parser'
require_relative 'slot_extractor'

module Dnd5e
  module Ingest
    module Parsers
      # Parses class feature tables from SRD text.
      class ClassTableParser
        include TableHandler
        include RowParser
        include SlotExtractor

        CLASS_HEADER = /^\s*([A-Z][a-z]+)\s+Features\s*$/
        LEVEL_ROW = /^\s*(\d+)\s+([+-]\d+)\s+(.*)$/
        # Lenient header detector
        HEADER_INDICATOR = /^\s*Level\s+.*Class\s+Features/

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
            # Avoid matching "As a Level 1 Character... listed in the Barbarian Features table."
            return if line.include?('table.')

            handle_new_class(match[1].strip, state, results)
          elsif state[:current_class]
            handle_table_content(line, state)
          end
        end

        def finalize_results(state, results)
          save_previous_table(state, results)
        end
      end
    end
  end
end
