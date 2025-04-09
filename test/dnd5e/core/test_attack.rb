require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/attack"
require_relative "../../../lib/dnd5e/core/statblock"
require_relative "../../../lib/dnd5e/core/dice"
require_relative "../../../lib/dnd5e/core/dice_roller"
require_relative "../../../lib/dnd5e/core/attack_resolver"
require_relative "../../../lib/dnd5e/builders/character_builder"
require_relative "../../../lib/dnd5e/builders/monster_builder"
require 'logger'

module Dnd5e
  module Core
    class TestAttack < Minitest::Test
      def setup
        @statblock = Statblock.new(name: "TestStatblock", strength: 14, dexterity: 12, constitution: 10, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8", level: 1)
        @mock_dice_roller = MockDiceRoller.new([100, 5]) # Attack roll, Damage roll
        @attack = Attack.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength, dice_roller: @mock_dice_roller)
        @hero = Builders::CharacterBuilder.new(name: "Hero")
                                          .with_statblock(@statblock.deep_copy)
                                          .with_attack(@attack)
                                          .build
        @goblin = Builders::MonsterBuilder.new(name: "Goblin 1")
                                          .with_statblock(@statblock.deep_copy)
                                          .with_attack(@attack)
                                          .build
        @silent_logger = Logger.new(nil)
        @attack_resolver = AttackResolver.new(logger: @silent_logger)
      end

      def test_initialize
        assert_equal "Sword", @attack.name
        assert_equal 1, @attack.damage_dice.count
        assert_equal 8, @attack.damage_dice.sides
        assert_equal :strength, @attack.relevant_stat
      end

      def test_attack_hits
        assert_equal true, @attack.attack(@hero, @goblin)
      end

      def test_attack_misses
        @mock_dice_roller = MockDiceRoller.new([1, 5]) # Attack roll, Damage roll
        @attack.instance_variable_set(:@dice_roller, @mock_dice_roller)
        assert_equal false, @attack.attack(@goblin, @hero)
      end

      def test_calculate_damage
        @mock_dice_roller = MockDiceRoller.new([5]) # Damage roll
        @attack.instance_variable_set(:@dice_roller, @mock_dice_roller)
        assert_equal 5, @attack.calculate_damage(@hero)
      end

      def test_resolve_attack_hits
        initial_hp = @goblin.statblock.hit_points
        @attack_resolver.resolve(@hero, @goblin, @attack)
        assert_equal initial_hp - 5, @goblin.statblock.hit_points
      end

      def test_resolve_attack_misses
        initial_hp = @hero.statblock.hit_points
        @mock_dice_roller = MockDiceRoller.new([1, 5]) # Attack roll, Damage roll
        @attack.instance_variable_set(:@dice_roller, @mock_dice_roller)
        @attack_resolver.resolve(@goblin, @hero, @attack)
        assert_equal initial_hp, @hero.statblock.hit_points
      end
    end
  end
end
