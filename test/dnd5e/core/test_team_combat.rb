require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/team_combat"
require_relative "../../../lib/dnd5e/core/team"
require_relative "factories"
require 'logger'

module Dnd5e
  module Core
    class TestTeamCombat < Minitest::Test
      include Factories

      def setup
        @hero1 = CharacterFactory.create_hero
        @hero2 = CharacterFactory.create_hero
        @goblin1 = MonsterFactory.create_goblin
        @goblin2 = MonsterFactory.create_goblin

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
        combat = TeamCombat.new(teams: [@heroes, @goblins], result_handler: @result_handler, logger: @logger, dice_roller: @mock_dice_roller)
        assert_equal [@heroes, @goblins], combat.teams
        assert_instance_of TurnManager, combat.turn_manager
      end

      def test_take_turn_selects_valid_defender
        combat = TeamCombat.new(teams: [@heroes, @goblins], result_handler: @result_handler, logger: @logger, dice_roller: @mock_dice_roller)
        combat.turn_manager.turn_order.each do |attacker|
          defender = combat.take_turn(attacker)
          next if defender.nil?
          refute_equal attacker.team, defender.team
        end
      end

      def test_is_over
        combat = TeamCombat.new(teams: [@heroes, @goblins], result_handler: @result_handler, logger: @logger, dice_roller: @mock_dice_roller)
        refute combat.is_over?
        @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)
        @goblin2.statblock.take_damage(@goblin2.statblock.hit_points)
        assert combat.is_over?
      end

      def test_winner
        combat = TeamCombat.new(teams: [@heroes, @goblins], result_handler: @result_handler, logger: @logger, dice_roller: @mock_dice_roller)
        @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)
        @goblin2.statblock.take_damage(@goblin2.statblock.hit_points)
        assert_equal @heroes, combat.winner
      end

      def test_take_turn_does_not_select_same_team
        combat = TeamCombat.new(teams: [@heroes, @goblins], result_handler: @result_handler, logger: @logger, dice_roller: @mock_dice_roller)
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
        hero_statblock = Statblock.new(name: "Hero Statblock", strength: 16, dexterity: 10, constitution: 15, hit_die: "d10", level: 1)
        goblin_statblock = Statblock.new(name: "Goblin Statblock", strength: 8, dexterity: 16, constitution: 10, hit_die: "d6", level: 1)
        mock_dice_roller1 = MockDiceRoller.new([100, 5]) # Attack roll, Damage roll
        mock_dice_roller2 = MockDiceRoller.new([0, 0]) # Attack roll, Damage roll
        sword_attack = Attack.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength, dice_roller: mock_dice_roller1)
        bite_attack = Attack.new(name: "Bite", damage_dice: Dice.new(1, 6), relevant_stat: :strength, dice_roller: mock_dice_roller2)

        hero1 = Character.new(name: "Hero 1", statblock: hero_statblock.deep_copy, attacks: [sword_attack])
        hero2 = Character.new(name: "Hero 2", statblock: hero_statblock.deep_copy, attacks: [sword_attack])
        goblin1 = Monster.new(name: "Goblin 1", statblock: goblin_statblock.deep_copy, attacks: [bite_attack])
        goblin2 = Monster.new(name: "Goblin 2", statblock: goblin_statblock.deep_copy, attacks: [bite_attack])

        heroes = Team.new(name: "Heroes", members: [hero1, hero2])
        goblins = Team.new(name: "Goblins", members: [goblin1, goblin2])

        combat = TeamCombat.new(teams: [heroes, goblins], result_handler: @result_handler, logger: @logger)
        combat.run_combat
        assert combat.is_over?
        assert_equal heroes, combat.winner, "Heroes that always hit should always win"
      end
    end
  end
end
