# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/team_combat'
require_relative '../../../lib/dnd5e/core/team'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/builders/monster_builder'

module Dnd5e
  module Core
    class Test2DMovement < Minitest::Test
      def setup
        @hero = Builders::CharacterBuilder.new(name: 'Hero')
                                          .as_fighter(level: 1, abilities: { strength: 16 })
                                          .build
        @goblin = Builders::MonsterBuilder.new(name: 'G').as_goblin.build

        # Place them at a 2D offset: Hero(0,0), Goblin(5,5)
        @combat = TeamCombat.new(teams: [
                                   Team.new(name: 'H', members: [@hero]),
                                   Team.new(name: 'M', members: [@goblin])
                                 ], distance: 10)

        # Manually override to 2D
        @combat.grid.move(@hero, Point2D.new(0, 0))
        @combat.grid.move(@goblin, Point2D.new(5, 5))
      end

      def test_hero_moves_diagonally_to_reach_goblin
        # Hero speed is 30, Goblin at (5,5) is only 5ft away (max(5,5)=5)
        # But let's move goblin further to force a move
        @combat.grid.move(@goblin, Point2D.new(15, 15))

        assert_equal 15, @combat.grid.distance(@hero, @goblin)

        @hero.start_turn
        @hero.strategy.execute_turn(@hero, @combat)

        # Hero should have moved to (15, 15) to attack (or adjacent)
        # Since it's a sword (5ft reach), hero should be within 5ft
        dist = @combat.grid.distance(@hero, @goblin)

        assert_operator dist, :<=, 5

        # Verify hero position is no longer (0,0)
        pos = @combat.grid.find_position(@hero)

        refute_equal Point2D.new(0, 0), pos
      end
    end
  end
end
