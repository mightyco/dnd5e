# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/builders/monster_builder'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/team'

module Dnd5e
  module Core
    class TestPaladinStrategy < Minitest::Test
      def setup
        initialize_paladin
        initialize_enemy
        initialize_combat
      end

      def initialize_paladin
        @builder = Builders::CharacterBuilder.new(name: 'Arthur')
        @paladin = @builder.as_paladin(level: 3, abilities: { strength: 16, charisma: 14 }).build
        @player_team = Dnd5e::Core::Team.new(name: 'Players', members: [@paladin])
        @paladin.team = @player_team
      end

      def initialize_enemy
        @enemy = Builders::MonsterBuilder.new(name: 'Zombie')
                                         .with_statblock(Dnd5e::Core::Statblock.new(name: 'Enemy', hit_points: 20,
                                                                                    armor_class: 10))
                                         .build
        @monster_team = Dnd5e::Core::Team.new(name: 'Monsters', members: [@enemy])
        @enemy.team = @monster_team
      end

      def initialize_combat
        @combat = Combat.new(combatants: [@paladin, @enemy])
      end

      def test_paladin_uses_sacred_weapon
        # Manually add Sacred Weapon feature to paladin for testing strategy
        sacred_weapon = Features::SacredWeapon.new
        @paladin.feature_manager.features << sacred_weapon

        # Strategy should try to activate it
        @paladin.strategy.execute_turn(@paladin, @combat)

        # Sacred Weapon usually consumes Channel Divinity and adds a condition
        assert @paladin.condition?(:sacred_weapon)
      end
    end
  end
end
