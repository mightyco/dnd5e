# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/builders/monster_builder'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/team'

module Dnd5e
  module Core
    class TestRangerStrategy < Minitest::Test
      def setup
        initialize_ranger
        initialize_enemy
        initialize_combat
        @ranger.start_turn
      end

      def initialize_ranger
        @builder = Builders::CharacterBuilder.new(name: 'Legolas')
        @ranger = @builder.as_ranger(level: 1, abilities: { dexterity: 16, wisdom: 14 }).build
        @player_team = Dnd5e::Core::Team.new(name: 'Players', members: [@ranger])
        @ranger.team = @player_team
      end

      def initialize_enemy
        @enemy = Builders::MonsterBuilder.new(name: 'Orc')
                                         .with_statblock(Dnd5e::Core::Statblock.new(name: 'Enemy', hit_points: 15,
                                                                                    armor_class: 10))
                                         .build
        @monster_team = Dnd5e::Core::Team.new(name: 'Monsters', members: [@enemy])
        @enemy.team = @monster_team
      end

      def initialize_combat
        @combat = Combat.new(combatants: [@ranger, @enemy])
      end

      def test_ranger_uses_ensnaring_strike_first
        # Ranger strategy now prioritizes Ensnaring Strike
        @ranger.statblock.resources.set_max(:lvl1_slots, 1)

        # Ensure it hits (low AC 10)
        @ranger.strategy.execute_turn(@ranger, @combat)

        # Ensnaring strike should have been triggered.
        # Since Orc has low STR, it likely failed save, but we check colossus slayer as a proxy
        # that an attack happened after bonus action.
        assert @ranger.turn_context.flags.key?(:ensnaring_strike_active), 'Should have used Ensnaring Strike'
      end

      def test_ranger_uses_hunters_mark_as_fallback
        # Out of slots for ensnaring strike, but has free Hunters Mark uses
        @ranger.statblock.resources.set_max(:lvl1_slots, 0)
        @ranger.statblock.resources.set_max(:hunters_mark, 1)

        @ranger.strategy.execute_turn(@ranger, @combat)

        # Hunter's Mark adds a condition
        assert @ranger.condition?(:hunters_mark_active)
      end
    end
  end
end
