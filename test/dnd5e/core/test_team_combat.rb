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

        # Create a silent logger for tests
        silent_logger = Logger.new(nil)
        @result_handler = PrintingCombatResultHandler.new(logger: silent_logger)
        @combat = TeamCombat.new(teams: [@heroes, @goblins], result_handler: @result_handler)
      end

      def test_combat_initialization
        assert_equal [@heroes, @goblins], @combat.teams
        assert_empty @combat.turn_order
      end

      def test_roll_initiative
        # Stub the Dice#roll method to return a specific value
        rolls = [[10], [10], [10], [10]]
        mock_dice = Minitest::Mock.new
        rolls.each do |roll_values|
          mock_dice.expect(:roll, roll_values)
        end
        Dice.stub(:new, ->(*_) { mock_dice }) do
          @combat.roll_initiative
        end
        assert_equal 4, @combat.turn_order.size
        @combat.turn_order.each do |combatant|
          assert combatant.instance_variable_get(:@initiative).is_a?(Integer)
        end
        mock_dice.verify
      end

      def test_sort_by_initiative
        initiative_rolls = {
          @hero1 => [15],
          @hero2 => [10],
          @goblin1 => [10],
          @goblin2 => [1]
        }

        mock_dice = Minitest::Mock.new
        initiative_rolls.each do |_, roll|
          mock_dice.expect(:roll, roll)
        end

        Dice.stub(:new, ->(*_) { mock_dice }) do
          @combat.roll_initiative
          @combat.sort_by_initiative
        end

        assert_equal @combat.turn_order[0], @hero1
        assert_equal @combat.turn_order[1], @goblin1, "#{@goblin1} wins ties because #{@goblin1.statblock.dexterity} > #{@hero2.statblock.dexterity}"
        assert_equal @combat.turn_order[2], @hero2
        assert_equal @combat.turn_order[3], @goblin2
        assert_equal @combat.turn_order.sort_by { |combatant| -combatant.instance_variable_get(:@initiative) }, @combat.turn_order
        mock_dice.verify
      end

      def test_take_turn_selects_valid_defender
        # Stub the Dice#roll method to return a specific value
        rolls = [[10], [10], [10], [10], [10], [10], [10], [10]]
        mock_dice = Minitest::Mock.new
        rolls.each do |roll_values|
          mock_dice.expect(:roll, roll_values)
        end

        Dice.stub(:new, ->(*_) { mock_dice }) do
          @combat.roll_initiative
          @combat.sort_by_initiative
          @combat.turn_order.each do |attacker|
            defender = @combat.take_turn(attacker)
            next if defender.nil?
            refute_equal attacker.team, defender.team
          end
        end
        mock_dice.verify
      end

      def test_is_over
        # Stub the Dice#roll method to return specific values
        rolls = [[20], [20], [20], [20]]
        mock_dice = Minitest::Mock.new
        rolls.each do |roll_values|
          mock_dice.expect(:roll, roll_values)
        end
        Dice.stub(:new, ->(*_) { mock_dice }) do
          @combat.roll_initiative
          refute @combat.is_over?
          @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)
          @goblin2.statblock.take_damage(@goblin2.statblock.hit_points)
          assert @combat.is_over?
        end
        mock_dice.verify
      end

      def test_winner
        # Stub the Dice#roll method to return specific values
        rolls = [[20], [20], [20], [20]]
        mock_dice = Minitest::Mock.new
        rolls.each do |roll_values|
          mock_dice.expect(:roll, roll_values)
        end
        Dice.stub(:new, ->(*_) { mock_dice }) do
          @combat.roll_initiative
          @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)
          @goblin2.statblock.take_damage(@goblin2.statblock.hit_points)
          assert_equal @heroes, @combat.winner
        end
        mock_dice.verify
      end

      def test_attack_same_team
        # Stub the Dice#roll method to return specific values for each attack
        rolls = [[1], [1], [1], [1], [1], [1], [1], [1]]
        mock_dice = Minitest::Mock.new
        rolls.each do |roll_values|
          mock_dice.expect(:roll, roll_values)
        end

        Dice.stub(:new, ->(*_) { mock_dice }) do
          @combat.roll_initiative
          @combat.sort_by_initiative

          initial_hero1_hp = @hero1.statblock.hit_points
          initial_hero2_hp = @hero2.statblock.hit_points
          initial_goblin1_hp = @goblin1.statblock.hit_points
          initial_goblin2_hp = @goblin2.statblock.hit_points

          @combat.turn_order.each do |combatant|
            @combat.take_turn(combatant)
          end

          assert_equal initial_hero1_hp, @hero1.statblock.hit_points
          assert_equal initial_hero2_hp, @hero2.statblock.hit_points
          assert_equal initial_goblin1_hp, @goblin1.statblock.hit_points
          assert_equal initial_goblin2_hp, @goblin2.statblock.hit_points
        end
        mock_dice.verify
      end
    end
  end
end
