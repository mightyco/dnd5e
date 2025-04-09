require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/attack"
require_relative "../../../lib/dnd5e/core/statblock"
require_relative "../../../lib/dnd5e/core/dice"
require_relative "../../../lib/dnd5e/core/dice_roller"
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
      end

      def test_initialize
        assert_equal "Sword", @attack.name
        assert_equal 1, @attack.damage_dice.count
        assert_equal 8, @attack.damage_dice.sides
        assert_equal :strength, @attack.relevant_stat
      end
    end
  end
end
