# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Builders
    class TestRogueBuilder < Minitest::Test
      def setup
        @builder = CharacterBuilder.new(name: 'Vax')
      end

      def test_build_level_1_rogue
        rogue = @builder.as_rogue(level: 1, abilities: { dexterity: 16 }).build

        assert_equal 'Vax', rogue.name
        assert_equal 1, rogue.statblock.level
        assert_equal 15, rogue.statblock.armor_class # Studded Leather (12) + Dex (3) wait, dex 16 is +3. 12+3=15.
        # Wait, Studded Leather is AC 12. Dex 16 is +3. Total 15.
      end

      def test_rogue_has_sneak_attack
        rogue = @builder.as_rogue(level: 1).build

        assert(rogue.feature_manager.features.any? { |f| f.name == 'Sneak Attack' })
      end

      def test_rogue_has_cunning_action_at_level_two
        rogue = @builder.as_rogue(level: 2).build

        assert(rogue.feature_manager.features.any? { |f| f.name == 'Cunning Action' })
      end

      def test_rogue_has_evasion_at_level_seven
        rogue = @builder.as_rogue(level: 7).build

        assert(rogue.feature_manager.features.any? { |f| f.name == 'Evasion' })
      end
    end
  end
end
