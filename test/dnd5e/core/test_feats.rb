# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/dice_roller'
require_relative '../../../lib/dnd5e/core/features/great_weapon_master'
require_relative '../../../lib/dnd5e/core/features/sharpshooter'

class TestFeats < Minitest::Test
  def setup
    @dice_roller = Dnd5e::Core::MockDiceRoller.new([15, 5, 15, 5])
    setup_attacker
    setup_defender
    setup_combat
  end

  def setup_attacker
    statblock = Dnd5e::Core::Statblock.new(name: 'Attacker', strength: 10, dexterity: 10, level: 5) # PB +3
    @attacker = Dnd5e::Core::Character.new(
      name: 'Attacker', statblock: statblock,
      features: [Dnd5e::Core::Features::GreatWeaponMaster.new, Dnd5e::Core::Features::Sharpshooter.new]
    )
    damage_dice = Dnd5e::Core::Dice.new(1, 8, modifier: 0)
    @attack = Dnd5e::Core::Attack.new(name: 'Heavy Weapon', damage_dice: damage_dice,
                                      dice_roller: @dice_roller, properties: [:heavy])
    @attacker.attacks << @attack
  end

  def setup_defender
    statblock = Dnd5e::Core::Statblock.new(name: 'Defender', strength: 10, dexterity: 10, hit_points: 100, ac: 10)
    @defender = Dnd5e::Core::Character.new(name: 'Defender', statblock: statblock)
  end

  def setup_combat
    @combat = Dnd5e::Core::Combat.new(combatants: [@attacker, @defender], dice_roller: @dice_roller)
  end

  def test_great_weapon_master_adds_proficiency_bonus_to_damage
    @attacker.start_turn
    result = @combat.attack(@attacker, @defender, attack: @attack)

    assert_equal 8, result.damage, 'Great Weapon Master should add Proficiency Bonus to damage'
  end

  def test_great_weapon_master_once_per_turn
    @attacker.start_turn
    @combat.attack(@attacker, @defender, attack: @attack) # First attack uses it

    result = @combat.attack(@attacker, @defender, attack: @attack) # Second attack should not use it

    assert_equal 5, result.damage, 'Great Weapon Master should only apply once per turn'
  end
end
