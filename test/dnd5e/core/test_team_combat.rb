require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/team_combat"
require_relative "../../../lib/dnd5e/core/team"
require_relative "../../../lib/dnd5e/builders/character_builder"
require_relative "../../../lib/dnd5e/builders/monster_builder"
require_relative "../../../lib/dnd5e/core/statblock"
require_relative "../../../lib/dnd5e/core/attack"
require_relative "../../../lib/dnd5e/core/dice"
require 'logger'

module Dnd5e
  module Core
    class TestTeamCombat < Minitest::Test
      def setup
        hero_statblock = Statblock.new(name: "Hero Statblock", strength: 16, dexterity: 10, constitution: 15, hit_die: "d10", level: 3)
        goblin_statblock = Statblock.new(name: "Goblin Statblock", strength: 8, dexterity: 14, constitution: 10, hit_die: "d6", level: 1)
        sword_attack = Attack.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength)
        bite_attack = Attack.new(name: "Bite", damage_dice: Dice.new(1, 6), relevant_stat: :dexterity)

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

        @heroes = Team.new(name: "Heroes", members: [@hero1, @hero2])
        @goblins = Team.new(name: "Goblins", members: [@goblin1, @goblin2])

        # Create a logger for tests
        @logger = Logger.new(nil)
        # @logger = Logger.new($stdout)
        # @logger.level = Logger::DEBUG

        @result_handler = PrintingCombatResultHandler.new(logger: @logger)
        @mock_dice_roller = MockDiceRoller.new([10, 10, 10, 10]) # Initiative rolls
      end

      def test_combat_initialization
        combat = TeamCombat.new(teams: [@heroes, @goblins], dice_roller: @mock_dice_roller)
        assert_equal [@heroes, @goblins], combat.teams
        assert_instance_of TurnManager, combat.turn_manager
      end

      def test_take_turn_selects_valid_defender
        combat = TeamCombat.new(teams: [@heroes, @goblins], dice_roller: @mock_dice_roller)
        combat.turn_manager.turn_order.each do |attacker|
          defender = combat.take_turn(attacker)
          next if defender.nil?
          refute_equal attacker.team, defender.team
        end
      end

      def test_is_over
        combat = TeamCombat.new(teams: [@heroes, @goblins], dice_roller: @mock_dice_roller)
        refute combat.is_over?
        @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)
        @goblin2.statblock.take_damage(@goblin2.statblock.hit_points)
        assert combat.is_over?
      end

      def test_winner
        combat = TeamCombat.new(teams: [@heroes, @goblins], dice_roller: @mock_dice_roller)
        @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)
        @goblin2.statblock.take_damage(@goblin2.statblock.hit_points)
        assert_equal @heroes, combat.winner
      end

      def test_take_turn_does_not_select_same_team
        combat = TeamCombat.new(teams: [@heroes, @goblins], dice_roller: @mock_dice_roller)
        # Iterate through each combatant in the turn order
        combat.turn_manager.turn_order.each do |attacker|
          # Get the potential defenders for the current attacker
          potential_defenders = combat.teams.reject { |team| team == attacker.team }.flat_map(&:alive_members)

          # If there are no potential defenders, skip to the next attacker
          next if potential_defenders.empty?

          # Call take_turn to get the selected defender
          defender = combat.take_turn(attacker)

          # Assert that the defender is not nil and is not on the same team as the attacker
          refute_nil defender
          refute_equal attacker.team, defender.team, "Attacker #{attacker.name} should not be able to target a member of their own team"
        end
      end

      def test_run_combat_ends_correctly
        100.times do
          hero_statblock = Statblock.new(name: "Hero Statblock", strength: 16, dexterity: 10, constitution: 15, hit_die: "d10", level: 1)
          goblin_statblock = Statblock.new(name: "Goblin Statblock", strength: 8, dexterity: 16, constitution: 10, hit_die: "d6", level: 1)
          mock_dice_roller1 = MockDiceRoller.new(Array.new(100, 100) + Array.new(100, 100)) # Heroes always hit
          mock_dice_roller2 = MockDiceRoller.new(Array.new(100, 0) + Array.new(100, 0)) # Monsters always miss
          sword_attack = Attack.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength, dice_roller: mock_dice_roller1)
          bite_attack = Attack.new(name: "Bite", damage_dice: Dice.new(1, 6), relevant_stat: :strength, dice_roller: mock_dice_roller2)
        
          hero1 = Character.new(name: "Hero 1", statblock: hero_statblock.deep_copy, attacks: [sword_attack])
          hero2 = Character.new(name: "Hero 2", statblock: hero_statblock.deep_copy, attacks: [sword_attack])
          goblin1 = Monster.new(name: "Goblin 1", statblock: goblin_statblock.deep_copy, attacks: [bite_attack])
          goblin2 = Monster.new(name: "Goblin 2", statblock: goblin_statblock.deep_copy, attacks: [bite_attack])
        
          heroes = Team.new(name: "Heroes", members: [hero1, hero2])
          goblins = Team.new(name: "Goblins", members: [goblin1, goblin2])
        
          # Create a MockDiceRoller for initiative rolls
          initiative_roller = MockDiceRoller.new([10, 10, 10, 10])
        
          # Pass the initiative_roller to TeamCombat
          combat = TeamCombat.new(teams: [heroes, goblins], dice_roller: initiative_roller)
          combat.run_combat
          assert combat.is_over?
          assert_equal heroes, combat.winner, "Heroes that always hit should always win"
        end
      end

    end
  end
end
