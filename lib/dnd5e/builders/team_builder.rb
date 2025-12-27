# frozen_string_literal: true

module Dnd5e
  module Builders
    # Builds a Team object with a fluent interface.
    #
    # @see Dnd5e::Builders
    class TeamBuilder
      # Error raised when an invalid team is built.
      class InvalidTeamError < StandardError; end

      # Initializes a new TeamBuilder.
      #
      # @param name [String] The name of the team.
      def initialize(name:)
        @name = name
        @members = []
      end

      # Adds a member to the team.
      #
      # @param member [Character, Monster] The member to add.
      # @return [TeamBuilder] The TeamBuilder instance.
      def with_member(member)
        @members << member
        self
      end

      # Builds the team.
      #
      # @return [Team] The built team.
      # @raise [InvalidTeamError] if the team is invalid.
      def build
        raise InvalidTeamError, 'Team must have a name' if @name.nil? || @name.empty?
        raise InvalidTeamError, 'Team must have at least one member' if @members.empty?

        Core::Team.new(name: @name, members: @members)
      end
    end
  end
end
