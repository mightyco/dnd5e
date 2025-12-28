# frozen_string_literal: true

require_relative '../../test_helper'

module Dnd5e
  module Core
    class TestCombatAttackHandler < Minitest::Test
      def setup
        @logger = Logger.new(nil) # Use a null logger for testing
        @dice_roller = MockDiceRoller.new([10, 5])
        @attack_handler = CombatAttackHandler.new(logger: @logger)
        @statblock1 = Statblock.new(name: 'Test Character 1', strength: 15, dexterity: 14, hit_die: 'd10')
        @statblock2 = Statblock.new(name: 'Test Character 2', strength: 10, dexterity: 10, hit_die: 'd10')
        @attack = Attack.new(name: 'Sword', damage_dice: Dice.new(1, 8), relevant_stat: :strength,
                             dice_roller: @dice_roller)
        @character1 = Character.new(name: 'Character 1', statblock: @statblock1, attacks: [@attack])
        @character2 = Character.new(name: 'Character 2', statblock: @statblock2, attacks: [@attack])
      end

      def test_initialization
        combat_attack_handler = CombatAttackHandler.new

        refute_nil combat_attack_handler.logger
        refute_nil combat_attack_handler.attack_resolver
      end

      def test_initialization_with_logger
        combat_attack_handler = CombatAttackHandler.new(logger: @logger)

        assert_equal @logger, combat_attack_handler.logger
      end

      def test_attack_with_valid_attacker_and_defender
        result = @attack_handler.attack(@character1, @character2)

        assert result.success
        assert_equal 5, @character2.statblock.hit_points
      end

      def test_attack_with_dead_attacker
        @character1.statblock.take_damage(10)
        assert_raises(InvalidAttackError) { @attack_handler.attack(@character1, @character2) }
      end

      def test_attack_with_dead_defender
        @character2.statblock.take_damage(10)
        assert_raises(InvalidAttackError) { @attack_handler.attack(@character1, @character2) }
      end

      def test_attack_miss
        @dice_roller = MockDiceRoller.new([5, 5])
        @attack = Attack.new(name: 'Sword', damage_dice: Dice.new(1, 8), relevant_stat: :strength,
                             dice_roller: @dice_roller)
        @character1 = Character.new(name: 'Character 1', statblock: @statblock1, attacks: [@attack])
        @attack_handler = CombatAttackHandler.new(logger: @logger)
        result = @attack_handler.attack(@character1, @character2)

        refute result.success
        assert_equal 10, @character2.statblock.hit_points
      end

      # Moved from test_combat.rb
      def test_attack_on_invalid_target
        # Kill the defender
        @character2.statblock.take_damage(@character2.statblock.hit_points)

        refute_predicate @character2.statblock, :alive?

        # Attempt to attack the dead defender
        assert_raises(InvalidAttackError) do
          @attack_handler.attack(@character1, @character2)
        end
      end
    end
  end
end
