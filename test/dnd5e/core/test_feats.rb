# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/dice_roller'
require_relative '../../../lib/dnd5e/core/features/great_weapon_master'
require_relative '../../../lib/dnd5e/core/features/sharpshooter'

class TestFeats < Minitest::Test
  def setup
    @dice_roller = Dnd5e::Core::MockDiceRoller.new([15, 5]) # Attack: 15, Damage: 5
    setup_attacker
    setup_defender
    setup_combat
  end

  def setup_attacker
    statblock = Dnd5e::Core::Statblock.new(name: 'Attacker', strength: 10, dexterity: 10)
    @attacker = Dnd5e::Core::Character.new(
      name: 'Attacker', statblock: statblock,
      features: [Dnd5e::Core::Features::GreatWeaponMaster.new, Dnd5e::Core::Features::Sharpshooter.new]
    )
    damage_dice = Dnd5e::Core::Dice.new(1, 8, modifier: 0)
    @attacker.attacks << Dnd5e::Core::Attack.new(name: 'Greatsword', hit_bonus: 0, damage_dice: damage_dice,
                                                 dice_roller: @dice_roller)
  end

  def setup_defender
    statblock = Dnd5e::Core::Statblock.new(name: 'Defender', strength: 10, dexterity: 10, hit_points: 20, ac: 10)
    @defender = Dnd5e::Core::Character.new(name: 'Defender', statblock: statblock)
  end

  def setup_combat
    @combat = Dnd5e::Core::Combat.new(combatants: [@attacker, @defender], dice_roller: @dice_roller)
  end

  def test_great_weapon_master_penalty_to_hit
    # Normal roll would be 15 + 0 = 15.
    # With GWM, it should be 15 + 0 - 5 = 10.

    # We need to verify the modifier passed to the dice roller,
    # OR verify the result if we can inspect the details.

    @combat.attack(@attacker, @defender, great_weapon_master: true)

    # MockDiceRoller doesn't easily expose the modifier used in the calculation
    # unless we inspect the Dice object created.
    # The attack roll creates a Dice object.

    # The first call to dice_roller was the attack roll.
    # roll_with_dice is used for attack rolls in the current implementation?
    # Let's check AttackRollHelper.

    # AttackRollHelper uses:
    # attack_dice = Dice.new(1, 20, modifier: modifier)
    # attack.dice_roller.roll_with_dice(attack_dice)

    attack_dice = @dice_roller.last_dice_params.first

    # Modifier should include the -5 penalty
    # Base mod is 0 (Strength 10)
    assert_equal(-5, attack_dice.modifier, 'Great Weapon Master should apply -5 penalty to hit')
  end

  def test_great_weapon_master_bonus_to_damage
    @combat.attack(@attacker, @defender, great_weapon_master: true)

    # The second call is the damage roll.
    damage_dice = @dice_roller.last_dice_params.last

    # Base mod is 0. GWM adds +10.
    assert_equal 10, damage_dice.modifier, 'Great Weapon Master should add +10 to damage'
  end

  def test_sharpshooter_penalty_to_hit
    # Same logic as GWM but different flag
    @dice_roller.calls.clear
    @dice_roller.last_dice_params.clear

    @combat.attack(@attacker, @defender, sharpshooter: true)
    attack_dice = @dice_roller.last_dice_params.first

    assert_equal(-5, attack_dice.modifier, 'Sharpshooter should apply -5 penalty to hit')
  end

  def test_sharpshooter_bonus_to_damage
    @dice_roller.calls.clear
    @dice_roller.last_dice_params.clear

    @combat.attack(@attacker, @defender, sharpshooter: true)
    damage_dice = @dice_roller.last_dice_params.last

    assert_equal 10, damage_dice.modifier, 'Sharpshooter should add +10 to damage'
  end
end
