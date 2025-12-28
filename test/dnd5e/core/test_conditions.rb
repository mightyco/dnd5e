# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/dice_roller'

class TestConditions < Minitest::Test
  def setup
    @dice_roller = Dnd5e::Core::MockDiceRoller.new([10, 5]) # Rolls 10, then 5

    @attacker = Dnd5e::Core::Character.new(name: 'Attacker', statblock: Dnd5e::Core::Statblock.new(name: 'Attacker'))
    @defender = Dnd5e::Core::Character.new(name: 'Defender', statblock: Dnd5e::Core::Statblock.new(name: 'Defender'))

    @combat = Dnd5e::Core::Combat.new(combatants: [@attacker, @defender], dice_roller: @dice_roller)
  end

  def test_prone_attacker_has_disadvantage
    @attacker.statblock.conditions << :prone
    # Create a melee attack (range 5)
    attack = Dnd5e::Core::Attack.new(name: 'Sword', damage_dice: Dnd5e::Core::Dice.new(1, 6), dice_roller: @dice_roller)
    @attacker.attacks << attack

    @combat.attack(@attacker, @defender)

    assert_includes @dice_roller.calls, :roll_with_disadvantage
  end

  def test_prone_defender_grants_advantage_to_melee
    @defender.statblock.conditions << :prone
    attack = Dnd5e::Core::Attack.new(name: 'Sword', damage_dice: Dnd5e::Core::Dice.new(1, 6),
                                     dice_roller: @dice_roller, range: 5)
    @attacker.attacks << attack

    @combat.attack(@attacker, @defender)

    assert_includes @dice_roller.calls, :roll_with_advantage
  end

  def test_prone_defender_grants_disadvantage_to_ranged
    @defender.statblock.conditions << :prone
    attack = Dnd5e::Core::Attack.new(name: 'Bow', damage_dice: Dnd5e::Core::Dice.new(1, 6), dice_roller: @dice_roller,
                                     range: 60)
    @attacker.attacks << attack

    @combat.attack(@attacker, @defender)

    assert_includes @dice_roller.calls, :roll_with_disadvantage
  end

  def test_restrained_defender_grants_advantage
    @defender.statblock.conditions << :restrained
    attack = Dnd5e::Core::Attack.new(name: 'Sword', damage_dice: Dnd5e::Core::Dice.new(1, 6), dice_roller: @dice_roller)
    @attacker.attacks << attack

    @combat.attack(@attacker, @defender)

    assert_includes @dice_roller.calls, :roll_with_advantage
  end
end
