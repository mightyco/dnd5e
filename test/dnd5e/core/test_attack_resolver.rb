# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/attack_resolver'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/dice'
require_relative '../../../lib/dnd5e/core/dice_roller'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/builders/monster_builder'
require 'logger'

module Dnd5e
  module Core
    class TestAttackResolver < Minitest::Test
      def setup
        create_shared_objects
        create_combatants
        @silent_logger = Logger.new(nil)
        @attack_resolver = AttackResolver.new(logger: @silent_logger)
      end

      def create_shared_objects
        @statblock = Statblock.new(name: 'TestStatblock', strength: 14, dexterity: 12, constitution: 10,
                                   intelligence: 8, wisdom: 16, charisma: 18, hit_die: 'd8', level: 1)
        @mock_dice_roller = MockDiceRoller.new([100, 5]) # Attack roll, Damage roll
        @attack = Attack.new(name: 'Sword', damage_dice: Dice.new(1, 8), relevant_stat: :strength,
                             dice_roller: @mock_dice_roller)
      end

      def create_combatants
        @hero = Builders::CharacterBuilder.new(name: 'Hero')
                                          .with_statblock(@statblock.deep_copy)
                                          .with_attack(@attack)
                                          .build
        @goblin = Builders::MonsterBuilder.new(name: 'Goblin 1')
                                          .with_statblock(@statblock.deep_copy)
                                          .with_attack(@attack)
                                          .build
      end

      def test_resolve_attack_hits
        initial_hp = @goblin.statblock.hit_points
        result = @attack_resolver.resolve(@hero, @goblin, @attack)

        assert_attack_success(result, initial_hp, 5)
        assert_equal :attack, result.type
        assert_equal 100, result.attack_roll # Mock roll
        assert_equal @goblin.statblock.armor_class, result.target_ac
      end

      def test_resolve_attack_misses
        initial_hp = @hero.statblock.hit_points
        @mock_dice_roller = MockDiceRoller.new([1, 5]) # Attack roll, Damage roll
        @attack.instance_variable_set(:@dice_roller, @mock_dice_roller)
        result = @attack_resolver.resolve(@goblin, @hero, @attack)

        assert_attack_miss(result, initial_hp)
      end

      def test_resolve_save_failure
        fireball = create_fireball_attack(MockDiceRoller.new([5, 20]))
        result = @attack_resolver.resolve(@hero, @goblin, fireball)

        assert_save_failure(result, 20)
      end

      def test_resolve_save_success_half_damage
        fireball = create_fireball_attack(MockDiceRoller.new([10, 20]))
        result = @attack_resolver.resolve(@hero, @goblin, fireball)

        assert_equal 0, @goblin.statblock.hit_points # 10 - 10 = 0
        refute result.success # Returns false on save success (failure for attacker)
        assert_equal 10, result.damage
      end

      def test_resolve_save_success_no_damage
        trip = create_trip_attack(MockDiceRoller.new([15, 10]))
        initial_hp = @goblin.statblock.hit_points
        result = @attack_resolver.resolve(@hero, @goblin, trip)

        assert_equal initial_hp, @goblin.statblock.hit_points
        refute result.success
        assert_equal 0, result.damage
      end

      def test_resolve_save_with_fixed_dc
        trap = create_trap_attack(MockDiceRoller.new([14, 10]))
        result = @attack_resolver.resolve(@hero, @goblin, trap)

        assert result.success # Attacker success (trap worked)
        assert_equal 15, result.save_dc
        assert_equal 14, result.save_roll
      end

      private

      def assert_attack_success(result, initial_hp, expected_damage)
        assert_equal initial_hp - expected_damage, @goblin.statblock.hit_points
        assert result.success
        assert_equal expected_damage, result.damage
      end

      def assert_attack_miss(result, initial_hp)
        assert_equal initial_hp, @hero.statblock.hit_points
        refute result.success
        assert_equal 0, result.damage
        assert_equal 1, result.attack_roll
      end

      def assert_save_failure(result, expected_damage)
        assert_equal 0, @goblin.statblock.hit_points
        assert result.success
        assert_equal expected_damage, result.damage
        assert_equal :save, result.type
        assert result.is_dead
      end

      def create_fireball_attack(dice_roller)
        Attack.new(name: 'Fireball', damage_dice: Dice.new(8, 6), type: :save,
                   save_ability: :dexterity, dc_stat: :intelligence,
                   half_damage_on_save: true, dice_roller: dice_roller)
      end

      def create_trip_attack(dice_roller)
        Attack.new(name: 'Trip', damage_dice: Dice.new(1, 6), type: :save,
                   save_ability: :strength, dc_stat: :strength,
                   half_damage_on_save: false, dice_roller: dice_roller)
      end

      def create_trap_attack(dice_roller)
        Attack.new(name: 'Trap', damage_dice: Dice.new(1, 10), type: :save,
                   save_ability: :dexterity, fixed_dc: 15, dice_roller: dice_roller)
      end
    end
  end
end
