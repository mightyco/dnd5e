module Dnd5e
  require_relative "dice"
  module Core
    class Team
      attr_reader :name, :members

      def initialize(name:, members: [])
        @name = name
        @members = members
        @members.each { |member| member.team = self }
      end

      def add_member(member)
        @members << member
        member.team = self
      end

      def all_members_defeated?
        @members.all? { |member| !member.statblock.is_alive? }
      end

      def any_members_alive?
        @members.any? { |member| member.statblock.is_alive? }
      end

      def alive_members
        @members.select { |member| member.statblock.is_alive? }
      end
    end
  end
end