require_relative "../../test_helper"

module Dnd5e
  module Core
    class TestCombatAttackHandler < Minitest::Test
      def setup
        @logger = Logger.new(nil) # Use a null logger for testing
        @dice_roller = MockDiceRoller.new([10, 5])
        @attack_resolver = AttackResolver.new(logger: @logger)
        @attack_handler = CombatAttackHandler.new(logger: @logger, attack_resolver: @attack_resolver)
        @statblock1 = Statblock.new(name: "Test Character 1", strength: 15, dexterity: 14, hit_die: "d10")
        @statblock2 = Statblock.new(name: "Test Character 2", strength: 10, dexterity: 10, hit_die: "d10")
        @attack = Attack.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength, dice_roller: @dice_roller)
        @character1 = Character.new(name: "Character 1", statblock: @statblock1, attacks: [@attack])
        @character2 = Character.new(name: "Character 2", statblock: @statblock2, attacks: [@attack])
      end

      def test_attack_with_valid_attacker_and_defender
        assert_equal true, @attack_handler.attack(@character1, @character2)
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
        @attack = Attack.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength, dice_roller: @dice_roller)
        @character1 = Character.new(name: "Character 1", statblock: @statblock1, attacks: [@attack])
        @attack_handler = CombatAttackHandler.new(logger: @logger, attack_resolver: @attack_resolver)
        assert_equal false, @attack_handler.attack(@character1, @character2)
        assert_equal 10, @character2.statblock.hit_points
      end
    end
  end
end
