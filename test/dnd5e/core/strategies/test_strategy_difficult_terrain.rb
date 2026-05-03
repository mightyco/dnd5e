# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/dnd5e/builders/character_builder'
require_relative '../../../../lib/dnd5e/core/combat'

module Dnd5e
  module Core
    module Strategies
      class TestStrategyDifficultTerrain < Minitest::Test
        def setup
          @builder = Builders::CharacterBuilder.new(name: 'Fighter')
          @fighter = @builder.as_fighter(level: 1).build
          @enemy = Builders::CharacterBuilder.new(name: 'Target').as_fighter(level: 1).build

          @combat = Combat.new(combatants: [@fighter, @enemy])
          # Fighter at (0,0), Enemy at (20,0)
          @combat.grid.clear
          @combat.grid.place(@fighter, Point2D.new(0, 0))
          @combat.grid.place(@enemy, Point2D.new(20, 0))

          @fighter.start_turn
        end

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def test_movement_respects_difficult_terrain_cost
          # Fighter speed is 30.
          # Target path: (0,0) -> (5,0) -> (10,0) -> (15,0)
          # Set (5,0) and (10,0) to difficult terrain.
          @combat.grid.set_terrain(Point2D.new(5, 0), :difficult)
          @combat.grid.set_terrain(Point2D.new(10, 0), :difficult)

          assert_equal 10, @combat.grid.movement_cost(Point2D.new(5, 0))
          assert_equal 10, @combat.grid.movement_cost(Point2D.new(10, 0))

          # Block alternative paths to force going through difficult terrain
          wall_builder = Builders::CharacterBuilder.new(name: 'Wall').as_fighter(level: 1)
          @combat.grid.place(wall_builder.build, Point2D.new(5, 5))
          @combat.grid.place(wall_builder.build, Point2D.new(5, -5))
          @combat.grid.place(wall_builder.build, Point2D.new(10, 5))
          @combat.grid.place(wall_builder.build, Point2D.new(10, -5))
          @combat.grid.place(wall_builder.build, Point2D.new(0, 5))
          @combat.grid.place(wall_builder.build, Point2D.new(0, -5))
          @combat.grid.place(wall_builder.build, Point2D.new(15, -5))

          @fighter.strategy.execute_turn(@fighter, @combat)

          pos = @combat.grid.find_position(@fighter)

          assert_equal Point2D.new(15, 0), pos
          assert_equal 25, @fighter.turn_context.movement_used
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
      end
    end
  end
end
