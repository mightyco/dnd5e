require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/team_combat"
require_relative "../../../lib/dnd5e/core/team"
require_relative "factories"

module Dnd5e
  module Core
    class TestTeamCombat < Minitest::Test
      include Factories

      class TestAttackHit < Attack
        def calculate_attack_roll(statblock, roll: nil)
          return 100
        end
      end

      class TestAttackMiss < Attack
        def calculate_attack_roll(statblock, roll: nil)
          return 0
        end
      end

      def setup
        @hero1 = CharacterFactory.create_hero
        @hero2 = CharacterFactory.create_hero
        @goblin1 = MonsterFactory.create_goblin
        @goblin2 = MonsterFactory.create_goblin
        @sword_attack = TestAttackHit.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength)
        @bite_attack = TestAttackMiss.new(name: "Bite", damage_dice: Dice.new(1, 6), relevant_stat: :strength)
        @hero1.attacks = [@sword_attack]
        @hero2.attacks = [@sword_attack]
        @goblin1.attacks = [@bite_attack]
        @goblin2.attacks = [@bite_attack]

        @heroes = Team.new(name: "Heroes", members: [@hero1, @hero2])
        @goblins = Team.new(name: "Goblins", members: [@goblin1, @goblin2])
        @combat = TeamCombat.new(teams: [@heroes, @goblins])
      end

      def test_combat_initialization
        assert_equal [@heroes, @goblins], @combat.teams
        assert_empty @combat.turn_order
      end

      def test_roll_initiative
        @combat.roll_initiative
        assert_equal 4, @combat.turn_order.size
        @combat.turn_order.each do |combatant|
          assert combatant.instance_variable_get(:@initiative).is_a?(Integer)
        end
      end

      def test_sort_by_initiative
        @combat.roll_initiative
        @combat.sort_by_initiative
        assert_equal @combat.turn_order.sort_by { |combatant| -combatant.instance_variable_get(:@initiative) }, @combat.turn_order
      end

      def test_take_turn_selects_valid_defender
        @combat.roll_initiative
        @combat.sort_by_initiative
        @combat.turn_order.each do |attacker|
          defender = @combat.take_turn(attacker)
          next if defender.nil?
          refute_equal attacker.team, defender.team
        end
      end

      def test_attack_hits
        @combat.roll_initiative
        @combat.sort_by_initiative
        initial_goblin_hp = @goblin1.statblock.hit_points
        @combat.attack(@hero1, @goblin1)
        assert_operator @goblin1.statblock.hit_points, :<, initial_goblin_hp
        initial_hero_hp = @hero1.statblock.hit_points
        @combat.attack(@goblin2, @hero1)
        assert_equal @hero1.statblock.hit_points, initial_hero_hp
      end

      def test_is_over
        refute @combat.is_over?
        @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)
        @goblin2.statblock.take_damage(@goblin2.statblock.hit_points)
        assert @combat.is_over?
      end

      def test_winner
        @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)
        @goblin2.statblock.take_damage(@goblin2.statblock.hit_points)
        assert_equal @heroes, @combat.winner
      end

      def test_attack_same_team
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
    end
  end
end
