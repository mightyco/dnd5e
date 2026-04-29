# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/dnd5e/ingest/parsers/class_table_parser'

module Dnd5e
  module Ingest
    module Parsers
      class TestClassTableParserDetails < Minitest::Test
        def setup
          @parser = ClassTableParser.new
        end

        def test_parse_empty_content
          result = @parser.parse('')

          assert_empty result[:class_tables]
        end

        def test_avoid_matching_table_instruction
          content = <<~TEXT
            As a Level 1 Character... listed in the Barbarian Features table.
            Barbarian Features
            Level  Proficiency Bonus  Class Features
            1      +2                 Rage
          TEXT
          result = @parser.parse(content)

          assert_equal 1, result[:class_tables].size
          assert_equal 'Rage', result[:class_tables]['Barbarian'][0][:features]
        end

        def test_parse_table_with_gaps
          content = <<~TEXT
            Monk Features
            Level  Proficiency Bonus  Class Features  Points
            1      +2                 Martial Arts    —
            2      +2                 Focus           2
          TEXT
          result = @parser.parse(content)

          assert_equal '—', result[:class_tables]['Monk'][0][:points]
          assert_equal '2', result[:class_tables]['Monk'][1][:points]
        end

        def test_nil_headers_and_values
          result = @parser.parse("Other Stuff\nNot a table")

          assert_empty result[:class_tables]
        end

        def test_malformed_row
          content = <<~TEXT
            Fighter Features
            Level Proficiency Class Features
            NotARow
          TEXT
          result = @parser.parse(content)

          assert_empty result[:class_tables]['Fighter'] || []
        end

        def test_ligature_and_special_chars
          content = <<~TEXT
            Fighter Features
            Level  Proﬁciency Bonus  Class Features
            1      +2                 Action
          TEXT
          result = @parser.parse(content)

          assert_equal '+2', result[:class_tables]['Fighter'][0][:proficiency_bonus]
        end

        def test_is_slot_header_direct_call
          assert @parser.send(:slot_header?, '1st')
          assert @parser.send(:slot_header?, 'Level 1')
          assert @parser.send(:slot_header?, 'Spell Slots')
          assert @parser.send(:slot_header?, 'Slots')
          assert @parser.send(:slot_header?, 'Slot Level')
          assert @parser.send(:slot_header?, '1')
          refute @parser.send(:slot_header?, 'Other')
        end

        def test_process_table_empty
          assert_empty @parser.send(:process_table, [], [])
        end

        def test_finalize_results_with_empty_state
          results = {}
          @parser.send(:finalize_results, { current_class: nil, table_data: [], headers: [] }, results)

          assert_empty results
        end
      end
    end
  end
end
