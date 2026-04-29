# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/builders/monster_builder'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/team'

module Dnd5e
  module Core
    class TestMonkStrategy < Minitest::Test
      def setup
        initialize_monk
        initialize_enemy
        initialize_combat
        @monk.start_turn
      end

      def initialize_monk
        @builder = Builders::CharacterBuilder.new(name: 'Lee')
        @monk = @builder.as_monk(level: 2, abilities: { dexterity: 16 }).build
        @player_team = Dnd5e::Core::Team.new(name: 'Players', members: [@monk])
        @monk.team = @player_team
      end

      def initialize_enemy
        @enemy = Builders::MonsterBuilder.new(name: 'Skeleton')
                                         .with_statblock(Dnd5e::Core::Statblock.new(name: 'Enemy', hit_points: 30,
                                                                                    armor_class: 10))
                                         .build
        @monster_team = Dnd5e::Core::Team.new(name: 'Monsters', members: [@enemy])
        @enemy.team = @monster_team
      end

      def initialize_combat
        @combat = Combat.new(combatants: [@monk, @enemy])
      end

      def test_monk_uses_martial_arts_bonus_attack
        # Monk should use bonus action for Unarmed Strike if they have a target
        @monk.strategy.execute_turn(@monk, @combat)

        # Verify bonus action was used
        refute_predicate @monk.turn_context, :bonus_action_available?
      end

      def test_monk_uses_flurry_of_blows
        # Manually add Flurry of Blows feature
        flurry = Features::FlurryOfBlows.new
        @monk.feature_manager.features << flurry

        # Monk has 2 Focus Points at level 2
        initial_focus = @monk.statblock.resources[:focus_points]

        @monk.strategy.execute_turn(@monk, @combat)

        # Verify focus point was consumed if flurry was used
        assert_equal initial_focus - 1, @monk.statblock.resources[:focus_points]
      end
    end
  end
end
