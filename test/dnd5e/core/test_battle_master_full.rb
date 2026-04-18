# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/features/battle_master'
require_relative '../../../lib/dnd5e/core/strategies/battle_master_strategy'
require_relative '../../../lib/dnd5e/core/team_combat'
require_relative '../../../lib/dnd5e/core/team'
require_relative '../../../lib/dnd5e/builders/monster_builder'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Core
    class TestBattleMasterFull < Minitest::Test
      def setup
        @hero = create_hero
        @hero.statblock.resources.set_max(:action_surge, 0)

        @target = Builders::MonsterBuilder.new(name: 'Target').as_goblin.build
        @target.statblock.hit_points = 100
        @combat = create_combat(@hero, @target)
      end

      def test_tactical_shift
        @hero.strategy.use_damage_maneuver = false
        @hero.start_turn
        @hero.strategy.execute_turn(@hero, @combat)

        resources = @hero.statblock.resources.resources

        # Moved 15ft closer from 20ft -> should be at 5ft
        assert_equal 5, @combat.distance
        assert_equal 4, resources[:superiority_dice]
        assert_equal 1, resources[:second_wind]
      end

      def test_trip_attack
        @combat.distance = 5
        @hero.start_turn

        mock = MockDiceRoller.new([15, 5, 4, 1])
        @hero.attacks.first.instance_variable_set(:@dice_roller, mock)

        @hero.strategy.execute_turn(@hero, @combat)

        assert_predicate @target, :prone?
      end

      def test_builder_assigns_battle_master_strategy
        assert_instance_of Strategies::BattleMasterStrategy, @hero.strategy
      end

      def test_pushing_attack
        @hero.strategy.define_singleton_method(:pick_maneuver) { |*_args| :pushing_attack }

        @combat.distance = 5
        @hero.start_turn

        mock = MockDiceRoller.new([15, 5, 4, 1])
        @hero.attacks.first.instance_variable_set(:@dice_roller, mock)

        @hero.strategy.execute_turn(@hero, @combat)

        # 5ft + 15ft push = 20ft
        assert_equal 20, @combat.distance
      end

      private

      def create_hero
        Builders::CharacterBuilder.new(name: 'BM Hero')
                                  .as_fighter(level: 3, abilities: { strength: 20, dexterity: 14 })
                                  .with_subclass(:battlemaster, level: 3)
                                  .build
      end

      def create_combat(hero, target)
        # Explicitly ensure we use TeamCombat for stationary grid logic
        TeamCombat.new(teams: [
                         Team.new(name: 'Heroes', members: [hero]),
                         Team.new(name: 'Monsters', members: [target])
                       ], distance: 20)
      end
    end
  end
end
