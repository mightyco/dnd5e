# frozen_string_literal: true

require_relative 'character_builder'
require_relative '../core/team'

module Dnd5e
  module Builders
    # Builder for creating standard D&D party compositions.
    class TeamBuilder
      class InvalidTeamError < StandardError; end

      def initialize(name: 'Adventurers')
        @name = name
        @level = 1
        @members = []
      end

      def with_level(level)
        @level = level
        self
      end

      def with_member(member)
        @members << member
        self
      end

      def as_classic_party
        add_tank('Fighter 1')
        add_healer('Cleric 1') # Using Wizard placeholder
        add_dps('Rogue 1')
        add_dps('Wizard 1')
        self
      end

      def add_tank(name)
        @members << CharacterBuilder.new(name: name).as_fighter(level: @level).build
        self
      end

      def add_healer(name)
        @members << CharacterBuilder.new(name: name).as_wizard(level: @level, subclass: :abjurer).build
        self
      end

      def add_dps(name)
        @members << if @members.size.even?
                      CharacterBuilder.new(name: name).as_rogue(level: @level).build
                    else
                      CharacterBuilder.new(name: name).as_wizard(level: @level, subclass: :evoker).build
                    end
        self
      end

      def build
        raise InvalidTeamError, 'Team must have a name' if @name.nil? || @name.empty?
        raise InvalidTeamError, 'Team must have at least one member' if @members.empty?

        Core::Team.new(name: @name, members: @members)
      end
    end
  end
end
