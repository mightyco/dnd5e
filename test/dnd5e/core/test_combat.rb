# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/dice_roller'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/builders/monster_builder'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/dice'
require 'logger'

module Dnd5e
  module Core
    class TestCombat < Minitest::Test
      class MockObserver
        attr_reader :events

        def initialize
          @events = []
        end

        def update(event, data)
          @events << { event: event, data: data }
        end
      end

      def setup
        create_statblocks
        create_attacks
        create_combatants
        create_logger
        create_combat
      end

      def create_statblocks
        @hero_statblock = Statblock.new(name: 'Hero Statblock', strength: 16, dexterity: 10, constitution: 15,
                                        hit_die: 'd10', level: 1)
        @goblin_statblock = Statblock.new(name: 'Goblin Statblock', strength: 8, dexterity: 16, constitution: 10,
                                          hit_die: 'd6', level: 1)
      end

      def create_attacks
        @mock_dice_roller1 = MockDiceRoller.new([100, 5])
        @mock_dice_roller2 = MockDiceRoller.new([0, 0])
        @sword_attack = Attack.new(name: 'Sword', damage_dice: Dice.new(1, 8), relevant_stat: :strength,
                                   dice_roller: @mock_dice_roller1)
        @bite_attack = Attack.new(name: 'Bite', damage_dice: Dice.new(1, 6), relevant_stat: :dexterity,
                                  dice_roller: @mock_dice_roller2)
      end

      def create_combatants
        @hero = Builders::CharacterBuilder.new(name: 'Hero')
                                          .with_statblock(@hero_statblock.deep_copy)
                                          .with_attack(@sword_attack)
                                          .build
        @goblin = Builders::MonsterBuilder.new(name: 'Goblin 1')
                                          .with_statblock(@goblin_statblock.deep_copy)
                                          .with_attack(@bite_attack)
                                          .build
      end

      def create_logger
        @logger = Logger.new(nil)
      end

      def create_combat
        @observer = MockObserver.new
        @combat = Combat.new(combatants: [@hero, @goblin])
        @combat.add_observer(@observer)
      end

      def test_combat_initialization
        assert_equal [@hero, @goblin], @combat.combatants
        assert_instance_of TurnManager, @combat.turn_manager
        # Logger is no longer publicly exposed and defaults to nil inside Combat if not provided
        # But we pass nil in setup, so it becomes Logger.new(nil) internally.
        # However, we can check combat_attack_handler.logger
        assert_instance_of Logger, @combat.combat_attack_handler.logger
      end

      def test_combat_ends
        hero_statblock = Statblock.new(name: 'Hero Statblock', strength: 16, dexterity: 10, constitution: 15,
                                       hit_die: 'd10', level: 1)
        goblin_statblock = Statblock.new(name: 'Goblin Statblock', strength: 8, dexterity: 16, constitution: 10,
                                         hit_die: 'd6', level: 1)
        sword_attack = Attack.new(name: 'Sword', damage_dice: Dice.new(1, 8), relevant_stat: :strength)
        bite_attack = Attack.new(name: 'Bite', damage_dice: Dice.new(1, 6), relevant_stat: :dexterity)

        hero = Builders::CharacterBuilder.new(name: 'Hero')
                                         .with_statblock(hero_statblock.deep_copy)
                                         .with_attack(sword_attack)
                                         .build
        goblin = Builders::MonsterBuilder.new(name: 'Goblin 1')
                                         .with_statblock(goblin_statblock.deep_copy)
                                         .with_attack(bite_attack)
                                         .build

        combat = Combat.new(combatants: [hero, goblin])
        combat.run_combat
        assert combat.is_over?
        assert combat.winner
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

      def test_combat_times_out_after_max_rounds
        # Set max rounds to 2
        combat = Combat.new(combatants: [@hero, @goblin], dice_roller: @mock_dice_roller, max_rounds: 2)
        # Set up dice rolls to always miss, and do 0 damage
        mock_dice_roller = MockDiceRoller.new([0, 0, 0, 0, 0, 0, 0, 0])
        combat.dice_roller = mock_dice_roller
        refute combat.is_over?
        assert_raises(CombatTimeoutError) do
          combat.run_combat
        end
        assert_equal 2, combat.instance_variable_get(:@round_counter)
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

      def test_combat_emits_events
        # Reset setup for this test specifically
        setup
        # Set rolls for a hit: 15 to hit, 100 damage (lethal)
        @mock_dice_roller1.rolls = [15, 100]

        # Kill the goblin so combat ends quickly after one attack or just let it play out?
        # If I want to see multiple rounds, I need more dice.
        # But if I just want to see events, one round is enough.
        # Let's ensure the goblin dies to make it short.
        # @goblin.statblock.hit_points = 1 # Make him weak
        # Actually statblock is deep copied, so I can just modify it.
        # But wait, character builder builds new statblocks.
        # Let's just mock dice to kill him.

        @combat.run_combat

        events = @observer.events.map { |e| e[:event] }
        assert_includes events, :combat_start
        # These might fail until I implement them, which is the point of TDD
      end
    end
  end
end
