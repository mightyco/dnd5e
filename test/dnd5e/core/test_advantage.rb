# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/dice_roller'

class TestAdvantage < Minitest::Test
  def setup
    @dice_roller = Dnd5e::Core::MockDiceRoller.new([10, 5]) # Rolls 10, then 5

    # Create dummy characters
    statblock1 = Dnd5e::Core::Statblock.new(name: 'Attacker', strength: 10, dexterity: 10)
    statblock2 = Dnd5e::Core::Statblock.new(name: 'Defender', strength: 10, dexterity: 10)

    @attacker = Dnd5e::Core::Character.new(name: 'Attacker', statblock: statblock1)
    @defender = Dnd5e::Core::Character.new(name: 'Defender', statblock: statblock2)

    # Give attacker a weapon
    damage_dice = Dnd5e::Core::Dice.new(1, 6)
    @attacker.attacks << Dnd5e::Core::Attack.new(name: 'Sword', hit_bonus: 0, damage_dice: damage_dice,
                                                 dice_roller: @dice_roller)

    @combat = Dnd5e::Core::Combat.new(combatants: [@attacker, @defender], dice_roller: @dice_roller)
  end

  def test_attack_with_advantage_calls_dice_roller_correctly
    # This should fail initially because combat.attack doesn't accept options
    # or pass them down.
    begin
      @combat.attack(@attacker, @defender, advantage: true)
    rescue ArgumentError
      # Expected if the method signature hasn't been updated yet
    end

    assert_includes @dice_roller.calls, :roll_with_advantage,
                    'Expected dice roller to receive :roll_with_advantage call'
  end

  def test_attack_with_disadvantage_calls_dice_roller_correctly
    @dice_roller.calls.clear
    begin
      @combat.attack(@attacker, @defender, disadvantage: true)
    rescue ArgumentError
      # Expected if the method signature hasn't been updated yet
    end

    assert_includes @dice_roller.calls, :roll_with_disadvantage,
                    'Expected dice roller to receive :roll_with_disadvantage call'
  end
end
