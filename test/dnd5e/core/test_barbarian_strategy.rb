# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/builders/monster_builder'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/team'

module Dnd5e
  module Core
    class TestBarbarianStrategy < Minitest::Test
      def setup
        initialize_barbarian
        initialize_enemy
        initialize_combat
        @barbarian.start_turn
      end

      def initialize_barbarian
        @builder = Builders::CharacterBuilder.new(name: 'Grog')
        @barbarian = @builder.as_barbarian(level: 1, abilities: { strength: 16 }).build
        @player_team = Dnd5e::Core::Team.new(name: 'Players', members: [@barbarian])
        @barbarian.team = @player_team
      end

      def initialize_enemy
        @enemy = Builders::MonsterBuilder.new(name: 'Goblin')
                                         .with_statblock(Dnd5e::Core::Statblock.new(name: 'Enemy', hit_points: 10,
                                                                                    armor_class: 10))
                                         .build
        @monster_team = Dnd5e::Core::Team.new(name: 'Monsters', members: [@enemy])
        @enemy.team = @monster_team
      end

      def initialize_combat
        @combat = Combat.new(combatants: [@barbarian, @enemy])
      end

      def test_barbarian_uses_rage
        # Barbarian should use rage if an enemy is in combat
        @barbarian.strategy.execute_turn(@barbarian, @combat)

        assert @barbarian.condition?(:raging)
        assert_equal 1, @barbarian.statblock.resources[:rage]
      end

      def test_barbarian_uses_reckless_attack
        # Need to capture if attack was reckless.
        # Strategy sets options[:reckless] = true and options[:advantage] = true

        # We can verify the side effect: reckless_defense condition
        @barbarian.strategy.execute_turn(@barbarian, @combat)

        assert @barbarian.condition?(:reckless_defense)
      end

      def test_barbarian_does_not_rage_if_no_target
        # Remove enemy
        combat = Combat.new(combatants: [@barbarian])
        @barbarian.strategy.execute_turn(@barbarian, combat)

        refute @barbarian.condition?(:raging)
      end
    end
  end
end
