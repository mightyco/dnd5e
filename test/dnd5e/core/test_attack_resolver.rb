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
    # Base class for AttackResolver tests containing setup and helper methods.
    class AttackResolverTestBase < Minitest::Test
      def setup
        create_shared_objects
        create_combatants
        @silent_logger = Logger.new(nil)
        @attack_resolver = AttackResolver.new(logger: @silent_logger)
      end

      private

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

    class TestAttackResolver < AttackResolverTestBase
      def test_resolve_critical_hit
        # Attack roll (20), Damage (simulated 2d8=11)
        # Note: 20 is rolled, AttackResolver should see it as a crit.
        # It should then take the attack's damage dice (1d8), create a new dice (2d8), and roll that.
        # We need the MockDiceRoller to return 11 for that second roll.

        @mock_dice_roller = MockDiceRoller.new([20, 11])
        # Force the underlying dice to have a roll of [20] so checking dice.rolls returns [20]
        # This is a bit of internal knowledge of how DiceRoller works, but necessary for mocking.
        # However, MockDiceRoller doesn't create a @dice object until roll is called unless we force it.
        # Actually, AttackResolver calls roll_with_dice/advantage which sets @dice.

        # When `roll_attack` is called, it calls `dice_roller.roll_with_dice`.
        # Our Mock `roll` method now updates `@dice.rolls` IF `@dice` exists.

        # But wait! `DiceRoller#roll_with_dice(dice)` sets `@dice = dice`.
        # So when `roll_attack` runs:
        # 1. Creates `attack_dice` (1d20).
        # 2. Calls `dice_roller.roll_with_dice(attack_dice)`.
        # 3. MockDiceRoller calls `super`? No, it overrides it.
        # 4. MockDiceRoller sets `@dice = dice` (inherited from DiceRoller? No, DiceRoller has it, Mock overrides it?)
        # Ah! MockDiceRoller OVERRIDES `roll_with_dice` and aliases `roll`.
        # The base `roll_with_dice` sets `@dice`. The Mock version does NOT call super, so `@dice` is never set!

        # FIX: We need MockDiceRoller to set @dice so that AttackResolver can inspect it.

        @attack.instance_variable_set(:@dice_roller, @mock_dice_roller)

        result = @attack_resolver.resolve(@hero, @goblin, @attack)

        assert result.success
        assert_equal 20, result.attack_roll

        last_dice = @mock_dice_roller.last_dice_params.last

        assert_equal 2, last_dice.count, 'Expected damage dice count to be 2 (doubled for crit)'
        assert_equal 8, last_dice.sides
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

      def test_resolve_with_advantage
        result = @attack_resolver.resolve(@hero, @goblin, @attack, advantage: true)

        assert_includes @mock_dice_roller.calls, :roll_with_advantage
        assert result.success
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
    end
  end
end
