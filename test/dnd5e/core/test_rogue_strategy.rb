# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/strategies/rogue_strategy'

class TestRogueStrategy < Minitest::Test
  def setup
    @rogue = Dnd5e::Core::Character.new(
      name: 'Rogue',
      statblock: Dnd5e::Core::Statblock.new(name: 'Rogue'),
      strategy: Dnd5e::Core::Strategies::RogueStrategy.new
    )
    @target = Dnd5e::Core::Character.new(name: 'Target', statblock: Dnd5e::Core::Statblock.new(name: 'Target'))

    @combat = Dnd5e::Core::Combat.new(combatants: [@rogue, @target])

    @dice_roller = Dnd5e::Core::MockDiceRoller.new([20, 10, 5]) # Init, Attack, Dmg
    @rogue.attacks << Dnd5e::Core::Attack.new(name: 'Dagger', damage_dice: Dnd5e::Core::Dice.new(1, 4),
                                              dice_roller: @dice_roller)

    # We need to inject dice roller into combat for consistency if needed, but attack has its own.
  end

  def test_rogue_hides_and_attacks_with_advantage
    # Initial state
    assert_predicate @rogue.turn_context, :bonus_action_available?
    refute_includes @rogue.statblock.conditions, :hidden

    # Execute turn
    @combat.take_turn(@rogue)

    # Verify Bonus Action used for Hide
    refute_predicate @rogue.turn_context, :bonus_action_available?, 'Bonus action should be used for hiding'

    # Verify Attack used with Advantage
    # We need to verify that 'roll_with_advantage' was called on the dice roller.
    assert_includes @dice_roller.calls, :roll_with_advantage, 'Rogue should attack with advantage after hiding'

    # Verify no longer hidden after attack
    refute_includes @rogue.statblock.conditions, :hidden
  end
end
