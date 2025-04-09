module Dnd5e
  require_relative "dice"
  module Core
    # Represents a team of characters or monsters in the D&D 5e system.
    class Team
      attr_reader :name, :members

      # Initializes a new Team.
      #
      # @param name [String] The name of the team.
      # @param members [Array<Character, Monster>] The members of the team.
      def initialize(name:, members: [])
        @name = name
        @members = members
        @members.each { |member| member.team = self }
      end

      # Adds a member to the team.
      #
      # @param member [Character, Monster] The member to add.
      def add_member(member)
        @members << member
        member.team = self
      end

      # Checks if all members of the team are defeated.
      #
      # @return [Boolean] True if all members are defeated, false otherwise.
      def all_members_defeated?
        @members.all? { |member| !member.statblock.is_alive? }
      end

      # Checks if any members of the team are alive.
      #
      # @return [Boolean] True if any members are alive, false otherwise.
      def any_members_alive?
        @members.any? { |member| member.statblock.is_alive? }
      end

      # Returns a list of the team's alive members.
      #
      # @return [Array<Character, Monster>] The alive members of the team.
      def alive_members
        @members.select { |member| member.statblock.is_alive? }
      end
    end
  end
end
