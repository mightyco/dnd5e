# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/team_builder'
require_relative '../../../lib/dnd5e/core/team'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/statblock'

module Dnd5e
  module Builders
    class TestTeamBuilder < Minitest::Test
      def setup
        @statblock = Core::Statblock.new(name: 'Test Statblock')
        @member = Core::Character.new(name: 'Test Member', statblock: @statblock)
      end

      def test_build_valid_team
        team = TeamBuilder.new(name: 'Test Team')
                          .with_member(@member)
                          .build

        assert_instance_of Core::Team, team
        assert_equal 'Test Team', team.name
        assert_includes team.members, @member
      end

      def test_build_missing_name
        assert_raises TeamBuilder::InvalidTeamError do
          TeamBuilder.new(name: nil).with_member(@member).build
        end
      end

      def test_build_no_members
        assert_raises TeamBuilder::InvalidTeamError do
          TeamBuilder.new(name: 'Test Team').build
        end
      end
    end
  end
end
