# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/turn_context'

class TestTurnContext < Minitest::Test
  def setup
    @context = Dnd5e::Core::TurnContext.new
  end

  def test_initial_state
    assert_equal 0, @context.actions_used
    assert_equal 0, @context.bonus_actions_used
    assert_equal 0, @context.reactions_used
    assert_equal 0, @context.movement_used
  end

  def test_use_action
    assert_predicate @context, :action_available?
    @context.use_action

    assert_equal 1, @context.actions_used
    refute_predicate @context, :action_available?

    assert_raises(RuntimeError) { @context.use_action }
  end

  def test_use_bonus_action
    assert_predicate @context, :bonus_action_available?
    @context.use_bonus_action

    assert_equal 1, @context.bonus_actions_used
    refute_predicate @context, :bonus_action_available?

    assert_raises(RuntimeError) { @context.use_bonus_action }
  end

  def test_reset
    @context.use_action
    @context.reset!

    assert_equal 0, @context.actions_used
    assert_predicate @context, :action_available?
  end
end

class TestCharacterTurnContext < Minitest::Test
  def setup
    statblock = Dnd5e::Core::Statblock.new(name: 'Hero')
    @character = Dnd5e::Core::Character.new(name: 'Hero', statblock: statblock)
  end

  def test_character_has_turn_context
    assert_kind_of Dnd5e::Core::TurnContext, @character.turn_context
  end

  def test_start_turn_resets_context
    @character.turn_context.use_action

    refute_predicate @character.turn_context, :action_available?

    @character.start_turn

    assert_predicate @character.turn_context, :action_available?
  end
end
