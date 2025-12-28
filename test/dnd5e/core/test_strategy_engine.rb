# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/strategies/simple_strategy'

class TestStrategyEngine < Minitest::Test
  def setup
    @attacker = Dnd5e::Core::Character.new(name: 'Attacker', statblock: Dnd5e::Core::Statblock.new(name: 'Attacker'))
    @defender = Dnd5e::Core::Character.new(name: 'Defender', statblock: Dnd5e::Core::Statblock.new(name: 'Defender'))

    # Mock combat
    @combat = Dnd5e::Core::Combat.new(combatants: [@attacker, @defender])

    # Give attacker an attack
    @dice_roller = Dnd5e::Core::MockDiceRoller.new([10, 5])
    @attacker.attacks << Dnd5e::Core::Attack.new(name: 'Sword', damage_dice: Dnd5e::Core::Dice.new(1, 6),
                                                 dice_roller: @dice_roller)
  end

  def test_simple_strategy_uses_action
    strategy = Dnd5e::Core::Strategies::SimpleStrategy.new
    @attacker.strategy = strategy

    assert_predicate @attacker.turn_context, :action_available?

    # Execute turn via combat (which calls strategy)
    @combat.take_turn(@attacker)

    refute_predicate @attacker.turn_context, :action_available?, 'Action should be used after taking turn'
  end

  def test_strategy_does_not_act_if_no_action
    strategy = Dnd5e::Core::Strategies::SimpleStrategy.new
    @attacker.strategy = strategy
    @attacker.turn_context.use_action # Pre-use action

    # Reset dice roller calls to verify no attack happened
    @dice_roller.calls.clear

    @combat.take_turn(@attacker)

    assert_empty @dice_roller.calls, 'Should not attack if action is already used'
  end
end
