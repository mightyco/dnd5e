# frozen_string_literal: true

require_relative '../../core/mechanic'

module Dnd5e
  module Ingest
    module Parsers
      # Parses core mechanics from text.
      class MechanicParser
        def parse(_content)
          # Placeholder: Could look for headers like "COMBAT" or "GRAPPLING"
          { mechanics: [] }
        end
      end
    end
  end
end
