# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/team'
require_relative '../../../lib/dnd5e/core/team_combat'
require_relative '../../../lib/dnd5e/core/strategies/simple_strategy'
require_relative '../../../lib/dnd5e/builders/character_builder'

class TestReactions < Minitest::Test
  def setup
    @dice_roller = Dnd5e::Core::MockDiceRoller.new([20, 5, 20, 5]) # High rolls to ensure hits
    setup_combatants
    setup_teams
    @combat = Dnd5e::Core::TeamCombat.new(teams: [@team1, @team2], dice_roller: @dice_roller)
    @combat.distance = 5
  end

  def test_opportunity_attack_triggers_when_moving_away
    initial_hp = @f1.statblock.hit_points
    @combat.move_combatant(@f1, 30)

    assert_operator @f1.statblock.hit_points, :<, initial_hp, 'F1 should have taken damage from OA'
    assert_equal 1, @f2.turn_context.reactions_used, 'F2 should have used its reaction'
  end

  private

  def setup_combatants
    @f1 = Dnd5e::Builders::CharacterBuilder.new(name: 'F1').as_fighter(level: 1).build
    @f2 = Dnd5e::Builders::CharacterBuilder.new(name: 'F2').as_fighter(level: 1).build
    @f2.attacks.first.instance_variable_set(:@dice_roller, @dice_roller)
  end

  def setup_teams
    @team1 = Dnd5e::Core::Team.new(name: 'Team 1', members: [@f1])
    @team2 = Dnd5e::Core::Team.new(name: 'Team 2', members: [@f2])
  end
end
