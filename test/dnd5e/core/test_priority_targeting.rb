# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/team'
require_relative '../../../lib/dnd5e/core/team_combat'
require_relative '../../../lib/dnd5e/core/strategies/simple_strategy'
require_relative '../../../lib/dnd5e/builders/character_builder'

class TestPriorityTargeting < Minitest::Test
  def setup
    @strategy = Dnd5e::Core::Strategies::SimpleStrategy.new
    setup_attacker
    setup_enemies
    @combat = Dnd5e::Core::TeamCombat.new(teams: [@team_attacker, @team_enemies])
  end

  def test_ai_prioritizes_low_hp_mage_over_tank
    # Run multiple times to ensure it's not random luck
    10.times do
      target = @strategy.send(:find_target, @attacker, @combat)

      assert_equal 'Mage', target.name, 'AI should consistently prioritize the Mage'
    end
  end

  private

  def setup_attacker
    @attacker = Dnd5e::Builders::CharacterBuilder.new(name: 'Attacker')
                                                 .as_fighter(level: 5)
                                                 .build
    @attacker.strategy = @strategy
    @team_attacker = Dnd5e::Core::Team.new(name: 'Attacker Team', members: [@attacker])
  end

  def setup_enemies
    @tank = Dnd5e::Builders::CharacterBuilder.new(name: 'Tank')
                                             .as_fighter(level: 5, abilities: { constitution: 18 })
                                             .build
    @mage = Dnd5e::Builders::CharacterBuilder.new(name: 'Mage')
                                             .as_wizard(level: 5)
                                             .build
    @team_enemies = Dnd5e::Core::Team.new(name: 'Enemies', members: [@tank, @mage])
  end
end
