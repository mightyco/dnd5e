# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/strategies/rogue_strategy'

class TestRogueStrategy < Minitest::Test
  def setup
    initialize_rogue
    initialize_target
    initialize_combat
    initialize_dice
    @rogue.start_turn
  end

  def initialize_rogue
    @rogue = Dnd5e::Core::Character.new(
      name: 'Rogue',
      statblock: Dnd5e::Core::Statblock.new(name: 'Rogue'),
      strategy: Dnd5e::Core::Strategies::RogueStrategy.new
    )
  end

  def initialize_target
    @target = Dnd5e::Core::Character.new(name: 'Target', statblock: Dnd5e::Core::Statblock.new(name: 'Target'))
  end

  def initialize_combat
    @combat = Dnd5e::Core::Combat.new(combatants: [@rogue, @target])
  end

  def initialize_dice
    @dice_roller = Dnd5e::Core::MockDiceRoller.new([20, 10, 5]) # Init, Attack, Dmg
    @rogue.attacks << Dnd5e::Core::Attack.new(name: 'Dagger', damage_dice: Dnd5e::Core::Dice.new(1, 4),
                                              dice_roller: @dice_roller)
  end

  def test_rogue_hides_and_attacks_with_advantage
    # Initial state
    assert_predicate @rogue.turn_context, :bonus_action_available?
    refute @rogue.condition?(:hidden)

    # Execute turn
    @combat.take_turn(@rogue)

    # Verify Bonus Action used for Hide
    refute_predicate @rogue.turn_context, :bonus_action_available?, 'Bonus action should be used for hiding'

    # Verify Attack used with Advantage
    # We need to verify that 'roll_with_advantage' was called on the dice roller.
    assert_includes @dice_roller.calls, :roll_with_advantage, 'Rogue should attack with advantage after hiding'

    # Verify no longer hidden after attack
    refute @rogue.condition?(:hidden)
  end
end
