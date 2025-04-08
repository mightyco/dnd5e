module Dnd5e
  module Builders
    class TeamBuilder
      class InvalidTeamError < StandardError; end

      def initialize(name:)
        @name = name
        @members = []
      end

      def with_member(member)
        @members << member
        self
      end

      def build
        raise InvalidTeamError, "Team must have a name" if @name.nil? || @name.empty?
        raise InvalidTeamError, "Team must have at least one member" if @members.empty?

        Core::Team.new(name: @name, members: @members)
      end
    end
  end
end
