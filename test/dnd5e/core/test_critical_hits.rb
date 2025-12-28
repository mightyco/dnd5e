# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/dice_roller'

class TestCriticalHits < Minitest::Test
  def setup
    # Mock rolls:
    # 1. Attack Roll: 20 (Crit)
    # 2. Damage Roll: 10 (arbitrary total damage for the mock)
    @dice_roller = Dnd5e::Core::MockDiceRoller.new([20, 10])

    statblock_attacker = Dnd5e::Core::Statblock.new(name: 'Attacker', strength: 10, dexterity: 10)
    statblock_defender = Dnd5e::Core::Statblock.new(name: 'Defender', strength: 10, dexterity: 10, hit_points: 20)

    @attacker = Dnd5e::Core::Character.new(name: 'Attacker', statblock: statblock_attacker)
    @defender = Dnd5e::Core::Character.new(name: 'Defender', statblock: statblock_defender)

    # Weapon: 1d8 + 2
    damage_dice = Dnd5e::Core::Dice.new(1, 8, modifier: 2)
    @attacker.attacks << Dnd5e::Core::Attack.new(name: 'Longsword', hit_bonus: 0, damage_dice: damage_dice,
                                                 dice_roller: @dice_roller)

    @combat = Dnd5e::Core::Combat.new(combatants: [@attacker, @defender], dice_roller: @dice_roller)
  end

  def test_critical_hit_doubles_damage_dice_count
    # Perform attack
    @combat.attack(@attacker, @defender)

    # Check the dice object passed for damage calculation
    # The first call is the attack roll, the second is the damage roll.
    # We check the last one.
    damage_dice_used = @dice_roller.last_dice_params.last

    # Original was 1d8, so Crit should be 2d8
    assert_equal 2, damage_dice_used.count, 'Critical hit should double the number of dice'
    assert_equal 8, damage_dice_used.sides, 'Dice sides should remain the same'
  end

  def test_critical_hit_preserves_modifier
    @combat.attack(@attacker, @defender)
    damage_dice_used = @dice_roller.last_dice_params.last

    # Modifier should still be 2 (modifiers are NOT doubled in 5e)
    assert_equal 2, damage_dice_used.modifier, 'Critical hit should not double the modifier'
  end
end
