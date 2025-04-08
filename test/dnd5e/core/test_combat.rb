require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/combat"
require_relative "../../../lib/dnd5e/core/dice_roller"
require_relative "../../../lib/dnd5e/builders/character_builder"
require_relative "../../../lib/dnd5e/builders/monster_builder"
require_relative "../../../lib/dnd5e/core/statblock"
require_relative "../../../lib/dnd5e/core/attack"
require_relative "../../../lib/dnd5e/core/dice"
require 'logger'

module Dnd5e
  module Core
    class TestCombat < Minitest::Test
      def setup
        @hero_statblock = Statblock.new(name: "Hero Statblock", strength: 16, dexterity: 10, constitution: 15, hit_die: "d10", level: 1)
        @goblin_statblock = Statblock.new(name: "Goblin Statblock", strength: 8, dexterity: 16, constitution: 10, hit_die: "d6", level: 1)
        @mock_dice_roller1 = MockDiceRoller.new([100, 5]) # Attack roll, Damage roll
        @mock_dice_roller2 = MockDiceRoller.new([0, 0]) # Attack roll, Damage roll
        @sword_attack = Attack.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength, dice_roller: @mock_dice_roller1)
        @bite_attack = Attack.new(name: "Bite", damage_dice: Dice.new(1, 6), relevant_stat: :strength, dice_roller: @mock_dice_roller2)

        @hero = Builders::CharacterBuilder.new(name: "Hero")
                                          .with_statblock(@hero_statblock.deep_copy)
                                          .with_attack(@sword_attack)
                                          .build
        @goblin = Builders::MonsterBuilder.new(name: "Goblin 1")
                                          .with_statblock(@goblin_statblock.deep_copy)
                                          .with_attack(@bite_attack)
                                          .build

        @logger = Logger.new(nil)
        # @logger = Logger.new($stdout)
        # @logger.level = Logger::DEBUG

        @combat = Combat.new(combatants: [@hero, @goblin], logger: @logger)
      end

      def test_combat_initialization
        assert_equal [@hero, @goblin], @combat.combatants
        assert_instance_of TurnManager, @combat.turn_manager
      end

      def test_combat_ends
        hero_statblock = Statblock.new(name: "Hero Statblock", strength: 16, dexterity: 10, constitution: 15, hit_die: "d10", level: 1)
        goblin_statblock = Statblock.new(name: "Goblin Statblock", strength: 8, dexterity: 16, constitution: 10, hit_die: "d6", level: 1)
        sword_attack = Attack.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength)
        bite_attack = Attack.new(name: "Bite", damage_dice: Dice.new(1, 6), relevant_stat: :dexterity)

        hero = Builders::CharacterBuilder.new(name: "Hero")
                                          .with_statblock(hero_statblock.deep_copy)
                                          .with_attack(sword_attack)
                                          .build
        goblin = Builders::MonsterBuilder.new(name: "Goblin 1")
                                          .with_statblock(goblin_statblock.deep_copy)
                                          .with_attack(bite_attack)
                                          .build

        combat = Combat.new(combatants: [hero, goblin], logger: @logger)
        combat.run_combat
        assert combat.is_over?
        assert combat.winner
      end

      def test_attack_applies_damage
        initial_hp = @goblin.statblock.hit_points
        @mock_dice_roller = MockDiceRoller.new([100, 5]) # Attack roll, Damage roll
        @combat = Combat.new(combatants: [@hero, @goblin], logger: @logger, dice_roller: @mock_dice_roller)
        @combat.attack(@hero, @goblin)
        assert_equal initial_hp - 5, @goblin.statblock.hit_points
      end

      def test_attack_and_miss
        initial_hp = @hero.statblock.hit_points
        @mock_dice_roller = MockDiceRoller.new([1, 5]) # Attack roll, Damage roll
        @combat = Combat.new(combatants: [@hero, @goblin], logger: @logger, dice_roller: @mock_dice_roller)
        @combat.attack(@goblin, @hero)
        assert_equal initial_hp, @hero.statblock.hit_points
      end

      def test_is_over
        refute @combat.is_over?
        @goblin.statblock.take_damage(1000)
        assert @combat.is_over?
      end

      def test_winner
        @goblin.statblock.take_damage(@goblin.statblock.hit_points)
        assert_equal @hero.name, @combat.winner.name
      end

      def test_combat_ends_correctly
        # Kill the goblin
        @goblin.statblock.take_damage(@goblin.statblock.hit_points)
        refute @goblin.statblock.is_alive?

        # Start the combat
        @combat.run_combat

        # Check that the combat is over
        assert @combat.is_over?
        assert_equal @hero, @combat.winner
      end

      def test_attacker_is_never_dead
        # Kill the hero
        @hero.statblock.take_damage(@hero.statblock.hit_points)
        refute @hero.statblock.is_alive?

        # Start the combat
        @combat.run_combat

        # Check that the combat is over
        assert @combat.is_over?
        assert_equal @goblin, @combat.winner
      end

      def test_attackers_choose_living_target
        # Kill the goblin
        @goblin.statblock.take_damage(@goblin.statblock.hit_points)
        refute @goblin.statblock.is_alive?

        # Start the combat
        @combat.run_combat

        # Check that the combat is over
        assert @combat.is_over?
        assert_equal @hero, @combat.winner
      end

      def test_attack_on_invalid_target
        assert @goblin.statblock.is_alive?
        # Kill the goblin
        @goblin.statblock.take_damage(@goblin.statblock.hit_points)
        refute @goblin.statblock.is_alive?

        # Attempt to attack the dead goblin
        assert_raises(InvalidAttackError) do
          @combat.attack(@hero, @goblin)
        end
      end

      # New Tests Below

      def test_combat_times_out_after_max_rounds
        # Set max rounds to 2
        combat = Combat.new(combatants: [@hero, @goblin], logger: @logger, dice_roller: @mock_dice_roller, max_rounds: 2)
        # Set up dice rolls to always miss, and do 0 damage
        mock_dice_roller = MockDiceRoller.new([0, 0, 0, 0, 0, 0, 0, 0])
        combat.dice_roller = mock_dice_roller
        refute combat.is_over?
        assert_raises(CombatTimeoutError) do
          combat.run_combat
        end
        assert_equal 2, combat.instance_variable_get(:@round_counter)
      end

      def test_attack_with_dead_attacker
        # Kill the hero
        @hero.statblock.take_damage(@hero.statblock.hit_points)
        refute @hero.statblock.is_alive?

        # Attempt to attack with the dead hero
        assert_raises(InvalidAttackError) do
          @combat.attack(@hero, @goblin)
        end
      end

      def test_combat_with_no_valid_targets
        # Kill both combatants
        @hero.statblock.take_damage(@hero.statblock.hit_points)
        @goblin.statblock.take_damage(@goblin.statblock.hit_points)
        refute @hero.statblock.is_alive?
        refute @goblin.statblock.is_alive?

        # Run combat
        @combat.run_combat

        # Check that combat is over
        assert @combat.is_over?
        assert_raises(InvalidWinnerError) do
          @combat.winner
        end
      end
    end
  end
end
