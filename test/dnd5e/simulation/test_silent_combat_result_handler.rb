require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/simulation/silent_combat_result_handler"
require_relative "../../../lib/dnd5e/core/team_combat"
require_relative "../../../lib/dnd5e/core/team"
require_relative "../../../lib/dnd5e/builders/character_builder"
require_relative "../../../lib/dnd5e/builders/monster_builder"
require_relative "../../../lib/dnd5e/core/statblock"
require_relative "../../../lib/dnd5e/core/attack"
require_relative "../../../lib/dnd5e/core/dice"

require 'logger'

module Dnd5e
  module Simulation
    class TestSilentCombatResultHandler < Minitest::Test
      def setup
        hero_statblock = Core::Statblock.new(name: "Hero Statblock", strength: 16, dexterity: 10, constitution: 15, hit_die: "d10", level: 3)
        goblin_statblock = Core::Statblock.new(name: "Goblin Statblock", strength: 8, dexterity: 14, constitution: 10, hit_die: "d6", level: 1)
        sword_attack = Core::Attack.new(name: "Sword", damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength)
        bite_attack = Core::Attack.new(name: "Bite", damage_dice: Core::Dice.new(1, 6), relevant_stat: :dexterity)

        @hero1 = Builders::CharacterBuilder.new(name: "Hero1")
                                           .with_statblock(hero_statblock.deep_copy)
                                           .with_attack(sword_attack)
                                           .build
        @hero2 = Builders::CharacterBuilder.new(name: "Hero2")
                                           .with_statblock(hero_statblock.deep_copy)
                                           .with_attack(sword_attack)
                                           .build
        @goblin1 = Builders::MonsterBuilder.new(name: "Goblin1")
                                            .with_statblock(goblin_statblock.deep_copy)
                                            .with_attack(bite_attack)
                                            .build
        @goblin2 = Builders::MonsterBuilder.new(name: "Goblin2")
                                            .with_statblock(goblin_statblock.deep_copy)
                                            .with_attack(bite_attack)
                                            .build

        @heroes = Core::Team.new(name: "Heroes", members: [@hero1, @hero2])
        @goblins = Core::Team.new(name: "Goblins", members: [@goblin1, @goblin2])

        @logger = Logger.new(nil)
        @handler = SilentCombatResultHandler.new

        @combat = Core::TeamCombat.new(teams: [@heroes, @goblins])
        @combat.add_observer(@handler)
      end

      def test_handle_result
        @combat.run_combat  # Calls handler and records init
        assert_equal 1, @handler.results.size
      end

      def test_results
        @combat.run_combat
        @handler.handle_result(@combat, @heroes, @goblins)
        assert_equal @handler.results, @handler.results
      end
    end
  end
end
