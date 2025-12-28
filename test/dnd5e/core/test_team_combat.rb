# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/team_combat'
require_relative '../../../lib/dnd5e/core/team'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/builders/monster_builder'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/dice'
require_relative '../../../lib/dnd5e/core/dice_roller'
require 'logger'

module Dnd5e
  module Core
    class TestTeamCombat < Minitest::Test
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
        create_teams
        create_combat
      end

      def create_statblocks
        @hero_statblock = Statblock.new(name: 'Hero Statblock', strength: 16, dexterity: 10, constitution: 15,
                                        hit_die: 'd10', level: 1)
        @goblin_statblock = Statblock.new(name: 'Goblin Statblock', strength: 8, dexterity: 16, constitution: 10,
                                          hit_die: 'd6', level: 1)
      end

      def create_attacks
        @mock_dice_roller = MockDiceRoller.new([15, 5]) # Hit, Damage
        @sword_attack = Attack.new(name: 'Sword', damage_dice: Dice.new(1, 8), relevant_stat: :strength,
                                   dice_roller: @mock_dice_roller)
        @bite_attack = Attack.new(name: 'Bite', damage_dice: Dice.new(1, 6), relevant_stat: :dexterity,
                                  dice_roller: @mock_dice_roller)
      end

      def create_combatants
        @hero1 = build_combatant(Builders::CharacterBuilder, 'Hero 1', @hero_statblock, @sword_attack)
        @hero2 = build_combatant(Builders::CharacterBuilder, 'Hero 2', @hero_statblock, @sword_attack)
        @goblin1 = build_combatant(Builders::MonsterBuilder, 'Goblin 1', @goblin_statblock, @bite_attack)
        @goblin2 = build_combatant(Builders::MonsterBuilder, 'Goblin 2', @goblin_statblock, @bite_attack)
      end

      def build_combatant(builder_class, name, statblock, attack)
        builder_class.new(name: name)
                     .with_statblock(statblock.deep_copy)
                     .with_attack(attack)
                     .build
      end

      def create_teams
        @heroes = Team.new(name: 'Heroes', members: [@hero1, @hero2])
        @goblins = Team.new(name: 'Goblins', members: [@goblin1, @goblin2])
      end

      def create_combat
        @observer = MockObserver.new
        @combat = TeamCombat.new(teams: [@heroes, @goblins])
        @combat.add_observer(@observer)
      end

      def test_combat_initialization
        assert_equal 4, @combat.combatants.size
        assert_equal [@heroes, @goblins], @combat.teams
        assert_instance_of TurnManager, @combat.turn_manager
      end

      def test_run_combat_ends_correctly
        kill_team(@goblins)

        @combat.run_combat

        assert_predicate @combat, :over?
        assert_equal @heroes, @combat.winner

        events = @observer.events.map { |e| e[:event] }

        assert_includes events, :combat_end
        assert_equal @heroes, @observer.events.find { |e| e[:event] == :combat_end }[:data][:winner]
      end

      def test_run_combat_multiple_rounds
        @mock_dice_roller.rolls = [15, 1, 15, 1, 15, 1, 15, 1] * 10

        @heroes.members.each { |m| m.statblock.hit_points = 2 }
        @goblins.members.each { |m| m.statblock.hit_points = 2 }

        @combat.run_combat

        assert_predicate @combat, :over?
      end

      private

      def kill_team(team)
        team.members.each { |m| m.statblock.take_damage(m.statblock.hit_points) }
      end
    end
  end
end
