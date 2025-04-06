require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/attack"
require_relative "../../../lib/dnd5e/core/statblock"
require_relative "../../../lib/dnd5e/core/dice"
require_relative "../../../lib/dnd5e/core/dice_roller"
require_relative "../../../lib/dnd5e/core/character"
require_relative "../../../lib/dnd5e/core/monster"
require 'logger'

module Dnd5e
  module Core
    class TestAttackRoll < Minitest::Test
      def setup
        @statblock = Statblock.new(name: "TestStatblock", strength: 14, dexterity: 12, constitution: 10, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8", level: 1)
        @mock_dice_roller = MockDiceRoller.new([100, 5]) # Attack roll, Damage roll
        @attack = Attack.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength, dice_roller: @mock_dice_roller)
        @hero = Character.new(name: "Hero", statblock: @statblock.deep_copy, attacks: [@attack])
        @goblin = Monster.new(name: "Goblin 1", statblock: @statblock.deep_copy, attacks: [@attack])
        @silent_logger = Logger.new(nil)
        @attack.instance_variable_set(:@logger, @silent_logger)
      end

      def test_initialize
        assert_equal "Sword", @attack.name
        assert_equal 1, @attack.damage_dice.count
        assert_equal 8, @attack.damage_dice.sides
        assert_equal :strength, @attack.relevant_stat
      end

      def test_attack_hits
        initial_hp = @goblin.statblock.hit_points
        @attack.attack(@hero, @goblin)
        assert_equal initial_hp - 5, @goblin.statblock.hit_points
      end

      def test_attack_misses
        initial_hp = @hero.statblock.hit_points
        @mock_dice_roller = MockDiceRoller.new([1, 5]) # Attack roll, Damage roll
        @attack.instance_variable_set(:@dice_roller, @mock_dice_roller)
        @attack.attack(@goblin, @hero)
        assert_equal initial_hp, @hero.statblock.hit_points
      end
    end
  end
end
