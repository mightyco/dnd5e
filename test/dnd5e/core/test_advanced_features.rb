# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/dice'
require_relative '../../../lib/dnd5e/core/dice_roller'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/core/features/great_weapon_master'

class TestAdvancedFeatures < Minitest::Test
  def setup
    @dice_roller = Dnd5e::Core::MockDiceRoller.new([10, 10, 5, 3, 3]) # Hit (10, 10), Damage (5), Sneak (3, 3)
  end

  def test_sneak_attack_adds_damage_with_advantage
    require_relative '../../../lib/dnd5e/core/features/sneak_attack'
    feature = Dnd5e::Core::Features::SneakAttack.new(dice_count: 2)
    setup_rogue_with_feature(feature)

    @combat = Dnd5e::Core::Combat.new(combatants: [@attacker, @defender])
    result = @combat.attack(@attacker, @defender, advantage: true)

    assert_equal 14, result.damage, 'Sneak Attack should add 2d6 extra damage'
  end

  def test_evasion_takes_zero_damage_on_successful_save
    require_relative '../../../lib/dnd5e/core/features/evasion'
    setup_evasion_test(success: true)

    result = @combat.attack(@attacker, @defender, attack: @fireball)

    assert_equal 0, result.damage, 'Evasion should reduce damage to 0 on a successful save'
  end

  def test_evasion_takes_half_damage_on_failed_save
    require_relative '../../../lib/dnd5e/core/features/evasion'
    setup_evasion_test(success: false)

    result = @combat.attack(@attacker, @defender, attack: @fireball)

    assert_equal 10, result.damage, 'Evasion should reduce damage to half on a failed save'
  end

  private

  def setup_rogue_with_feature(feature)
    stat = Dnd5e::Core::Statblock.new(name: 'Rogue', dexterity: 16)
    @attacker = Dnd5e::Core::Character.new(name: 'Rogue', statblock: stat, features: [feature])
    damage_dice = Dnd5e::Core::Dice.new(1, 4, modifier: 3)
    @attacker.attacks << Dnd5e::Core::Attack.new(name: 'Dagger', damage_dice: damage_dice, dice_roller: @dice_roller)
    @defender = Dnd5e::Core::Character.new(name: 'Target', statblock: Dnd5e::Core::Statblock.new(name: 'Target'))
  end

  def setup_evasion_test(success:)
    feature = Dnd5e::Core::Features::Evasion.new
    stat = Dnd5e::Core::Statblock.new(name: 'Rogue', dexterity: 10)
    @defender = Dnd5e::Core::Character.new(name: 'Rogue', statblock: stat, features: [feature])
    @attacker = Dnd5e::Core::Character.new(name: 'Wizard', statblock: Dnd5e::Core::Statblock.new(name: 'Wizard'))

    @fireball = Dnd5e::Core::Attack.new(
      name: 'Fireball', damage_dice: Dnd5e::Core::Dice.new(8, 6),
      type: :save, save_ability: :dexterity, fixed_dc: 15, half_damage_on_save: true,
      dice_roller: @dice_roller
    )

    prepare_dice_and_combat(success)
  end

  def prepare_dice_and_combat(success)
    @dice_roller.rolls = success ? [15, 20] : [5, 20]
    @dice_roller.index = 0
    @combat = Dnd5e::Core::Combat.new(combatants: [@attacker, @defender])
  end
end
