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
      def setup
        create_statblocks
        create_attacks
        create_combatants
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

      def create_combat
        @observer = MockObserver.new
        @combat = Combat.new(combatants: [@hero, @goblin])
        @combat.add_observer(@observer)
      end

      def test_combat_initialization
        assert_equal [@hero, @goblin], @combat.combatants
        assert_instance_of TurnManager, @combat.turn_manager
        assert_instance_of Logger, @combat.combat_attack_handler.logger
      end

      def test_combat_ends_when_one_dies
        @goblin.statblock.take_damage(1000)

        assert_predicate @combat, :over?
        assert_equal @hero.name, @combat.winner.name
      end

      def test_run_combat_flow
        # Kill the goblin
        @goblin.statblock.take_damage(@goblin.statblock.hit_points)

        refute_predicate @goblin.statblock, :alive?

        @combat.run_combat

        assert_predicate @combat, :over?
        assert_equal @hero, @combat.winner
      end

      def test_attacker_is_never_dead
        # Kill the hero to see if goblin wins
        @hero.statblock.take_damage(@hero.statblock.hit_points)
        @combat.run_combat

        assert_predicate @combat, :over?
        assert_equal @goblin, @combat.winner
      end

      def test_combat_times_out
        combat = Combat.new(combatants: [@hero, @goblin], dice_roller: MockDiceRoller.new([0] * 10), max_rounds: 2)
        assert_raises(CombatTimeoutError) { combat.run_combat }
        assert_equal 2, combat.instance_variable_get(:@round_counter)
      end

      def test_combat_with_no_valid_targets
        # Kill everyone
        @hero.statblock.take_damage(@hero.statblock.hit_points)
        @goblin.statblock.take_damage(@goblin.statblock.hit_points)

        @combat.run_combat

        assert_predicate @combat, :over?
        assert_raises(InvalidWinnerError) { @combat.winner }
      end

      def test_combat_emits_events
        # Reset to ensure clean state and specific dice
        @mock_dice_roller1.rolls = [15, 100]
        # Ensure fast combat
        @goblin.statblock.hit_points = 1

        @combat.run_combat

        events = @observer.events.map { |e| e[:event] }

        assert_includes events, :combat_start
        assert_includes events, :round_start
        assert_includes events, :combat_end
      end

      # Simple MockObserver defined here to avoid dependency issues if moved
      class MockObserver
        attr_reader :events

        def initialize
          @events = []
        end

        def update(event, data)
          @events << { event: event, data: data }
        end
      end
    end
  end
end
