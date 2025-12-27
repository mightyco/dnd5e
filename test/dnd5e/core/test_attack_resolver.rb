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
        @statblock = Statblock.new(name: 'TestStatblock', strength: 14, dexterity: 12, constitution: 10,
                                   intelligence: 8, wisdom: 16, charisma: 18, hit_die: 'd8', level: 1)
        @mock_dice_roller = MockDiceRoller.new([100, 5]) # Attack roll, Damage roll
        @attack = Attack.new(name: 'Sword', damage_dice: Dice.new(1, 8), relevant_stat: :strength,
                             dice_roller: @mock_dice_roller)
        @hero = Builders::CharacterBuilder.new(name: 'Hero')
                                          .with_statblock(@statblock.deep_copy)
                                          .with_attack(@attack)
                                          .build
        @goblin = Builders::MonsterBuilder.new(name: 'Goblin 1')
                                          .with_statblock(@statblock.deep_copy)
                                          .with_attack(@attack)
                                          .build
        @silent_logger = Logger.new(nil)
        @attack_resolver = AttackResolver.new(logger: @silent_logger)
      end

      def test_resolve_attack_hits
        initial_hp = @goblin.statblock.hit_points
        result = @attack_resolver.resolve(@hero, @goblin, @attack)
        assert_equal initial_hp - 5, @goblin.statblock.hit_points
        assert result.success
        assert_equal 5, result.damage
        assert_equal :attack, result.type
        assert_equal 100, result.attack_roll # Mock roll
        assert_equal @goblin.statblock.armor_class, result.target_ac
      end

      def test_resolve_attack_misses
        initial_hp = @hero.statblock.hit_points
        @mock_dice_roller = MockDiceRoller.new([1, 5]) # Attack roll, Damage roll
        @attack.instance_variable_set(:@dice_roller, @mock_dice_roller)
        result = @attack_resolver.resolve(@goblin, @hero, @attack)
        assert_equal initial_hp, @hero.statblock.hit_points
        refute result.success
        assert_equal 0, result.damage
        assert_equal 1, result.attack_roll
      end

      def test_resolve_save_failure
        # Fireball: Save Dex, DC Int.
        # Attacker Int 8 (-1), Prof +2 => DC = 8 + 2 - 1 = 9.
        # Defender Dex 12 (+1). Save Mod +1.
        # Save Roll 5 => Total 6. Fail.
        # Damage 20.

        mock_dice = MockDiceRoller.new([5, 20]) # Save roll, Damage roll
        fireball = Attack.new(
          name: 'Fireball',
          damage_dice: Dice.new(8, 6),
          type: :save,
          save_ability: :dexterity,
          dc_stat: :intelligence,
          half_damage_on_save: true,
          dice_roller: mock_dice
        )

        @goblin.statblock.hit_points
        # 5 (save) < 9 (DC) => Fail => Full damage (20)
        # Note: Goblin HP is 10. Should be defeated/0 HP.

        # Override take_damage behavior or check clamping?
        # Statblock clamps at 0.

        result = @attack_resolver.resolve(@hero, @goblin, fireball)

        assert_equal 0, @goblin.statblock.hit_points
        assert result.success # Returns true on failure (success for attacker)
        assert_equal 20, result.damage
        assert_equal :save, result.type
        assert_equal 5, result.save_roll # Mock returns exact value
        assert_equal 9, result.save_dc
        assert result.is_dead
      end

      def test_resolve_save_success_half_damage
        # Fireball: Save Dex, DC Int. DC 9.
        # Defender Dex +1.
        # Save Roll 10 => Total 11. Success.
        # Damage 20. Half = 10.

        mock_dice = MockDiceRoller.new([10, 20]) # Save roll, Damage roll
        fireball = Attack.new(
          name: 'Fireball',
          damage_dice: Dice.new(8, 6),
          type: :save,
          save_ability: :dexterity,
          dc_stat: :intelligence,
          half_damage_on_save: true,
          dice_roller: mock_dice
        )

        @goblin.statblock.hit_points # 10
        # 10 (save) > 9 (DC) => Success => Half damage (10)

        result = @attack_resolver.resolve(@hero, @goblin, fireball)

        assert_equal 0, @goblin.statblock.hit_points # 10 - 10 = 0
        refute result.success # Returns false on save success (failure for attacker)
        assert_equal 10, result.damage
      end

      def test_resolve_save_success_no_damage
        # Trip: Save Str, DC Str.
        # Attacker Str 14 (+2), Prof +2 => DC 12.
        # Defender Str 14 (+2).
        # Save Roll 15 => Total 17. Success.
        # Damage 10. Half = False.

        mock_dice = MockDiceRoller.new([15, 10]) # Save roll, Damage roll
        trip = Attack.new(
          name: 'Trip',
          damage_dice: Dice.new(1, 6),
          type: :save,
          save_ability: :strength,
          dc_stat: :strength,
          half_damage_on_save: false,
          dice_roller: mock_dice
        )

        initial_hp = @goblin.statblock.hit_points

        result = @attack_resolver.resolve(@hero, @goblin, trip)

        assert_equal initial_hp, @goblin.statblock.hit_points
        refute result.success
        assert_equal 0, result.damage
      end

      def test_resolve_save_with_fixed_dc
        # Trap: DC 15 Fixed.
        # Defender Dex +1.
        # We want a result of 14 (Fail).
        # Since MockDiceRoller returns the *total*, we mock 14.

        mock_dice = MockDiceRoller.new([14, 10]) # Save roll (Total), Damage roll
        trap = Attack.new(
          name: 'Trap',
          damage_dice: Dice.new(1, 10),
          type: :save,
          save_ability: :dexterity,
          fixed_dc: 15,
          dice_roller: mock_dice
        )

        # Save 14 < 15 => Fail.
        result = @attack_resolver.resolve(@hero, @goblin, trap)

        assert result.success # Attacker success (trap worked)
        assert_equal 15, result.save_dc
        assert_equal 14, result.save_roll
      end
    end
  end
end
