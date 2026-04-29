# frozen_string_literal: true

module Dnd5e
  module Ingest
    module Parsers
      # Slot extraction for ClassTableParser.
      module SlotExtractor
        private

        def slot_header?(header)
          return false unless header

          header.match?(/^(?:\d+(?:st|nd|rd|th)|Level\s+\d+|\d+|Spell\s+Slots|Slots|Slot\s+Level)$/) ||
            (header == 'Level' && result_has_slots_header?(header))
        end

        def result_has_slots_header?(_header)
          true
        end

        def extract_slots(values, headers)
          warlock_slots = extract_warlock_slots(values, headers)
          return warlock_slots if warlock_slots

          extract_standard_slots(values, headers)
        end

        def extract_warlock_slots(values, headers)
          slots_idx = headers.index { |h| ['Spell Slots', 'Slots'].include?(h) }
          lvl_idx = headers.index { |h| ['Slot Level', 'Level'].include?(h) }

          return nil unless slots_idx && lvl_idx

          count = values[slots_idx].to_i
          level = values[lvl_idx].to_i
          res = Array.new(9, 0)
          res[level - 1] = count if level.positive? && level <= 9
          res
        end

        def extract_standard_slots(values, headers)
          indices = find_slot_indices(headers)
          return nil if indices.empty?

          slots = indices.map { |i| values[i] }
          format_slot_array(slots)
        end

        def find_slot_indices(headers)
          headers.each_with_index.select do |h, _i|
            h.match?(/^(?:\d+(?:st|nd|rd|th)|Level\s+\d+|\d+)$/)
          end.map(&:last)
        end

        def format_slot_array(slots)
          slots.map { |v| v == '—' || v.nil? ? 0 : v.to_i } + Array.new(9 - slots.size, 0)
        end
      end
    end
  end
end
