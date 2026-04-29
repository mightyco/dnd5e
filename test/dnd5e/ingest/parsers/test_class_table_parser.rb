# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/dnd5e/ingest/parsers/class_table_parser'

module Dnd5e
  module Ingest
    module Parsers
      class TestClassTableParserFoundation < Minitest::Test
        def setup
          @parser = ClassTableParser.new
        end

        def test_parse_basic_table_size
          result = @parser.parse(basic_table_content)
          tables = result[:class_tables]

          assert_equal 1, tables.size
          assert_equal 2, tables['Fighter'].size
        end

        def test_parse_basic_table_row1
          result = @parser.parse(basic_table_content)
          row = result[:class_tables]['Fighter'][0]

          assert_equal 1, row[:level]
          assert_equal 'Fighting Style, Second Wind', row[:features]
        end

        def basic_table_content
          <<~TEXT
            Fighter Features
            Level  Proficiency Bonus  Class Features
            1      +2                 Fighting Style, Second Wind
            2      +2                 Action Surge
          TEXT
        end

        def test_parse_wizard_lvl1_slots
          result = @parser.parse(wizard_table_content)

          assert_equal 2, result[:class_tables]['Wizard'][0][:slots][0]
        end

        def test_parse_wizard_lvl1_slots_none
          result = @parser.parse(wizard_table_content)

          assert_equal 0, result[:class_tables]['Wizard'][0][:slots][1]
        end

        def test_parse_wizard_lvl2_slots
          result = @parser.parse(wizard_table_content)

          assert_equal 3, result[:class_tables]['Wizard'][1][:slots][0]
        end

        def wizard_table_content
          <<~TEXT
            Wizard Features
            Level  Proficiency Bonus  Class Features  1  2
            1      +2                 Spellcasting    2  —
            2      +2                 Scholar         3  —
          TEXT
        end

        def test_parse_warlock_slots_l1
          result = @parser.parse(warlock_table_content)

          assert_equal [1, 0, 0, 0, 0, 0, 0, 0, 0], result[:class_tables]['Warlock'][0][:slots]
        end

        def test_parse_warlock_slots_l2
          result = @parser.parse(warlock_table_content)

          assert_equal [2, 0, 0, 0, 0, 0, 0, 0, 0], result[:class_tables]['Warlock'][1][:slots]
        end

        def warlock_table_content
          <<~TEXT
            Warlock Features
            Level  Bonus  Class Features  Invocations  Slots  Level
            1      +2     Pact Magic      1            1      1
            2      +2     Cunning         3            2      1
          TEXT
        end

        def test_multi_line_features
          content = <<~TEXT
            Wizard Features
            Level  Proficiency Bonus  Class Features  1
            1      +2                 Spellcasting,
                                      Arcane Recovery  2
          TEXT

          result = @parser.parse(content)
          tables = result[:class_tables]

          assert_equal 'Spellcasting, Arcane Recovery', tables['Wizard'][0][:features]
          assert_equal 2, tables['Wizard'][0][:slots][0]
        end
      end
    end
  end
end
