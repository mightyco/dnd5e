require_relative "statblock"
require_relative "attack"

module Dnd5e
  module Core
    # Represents a monster in the D&D 5e system.
    # A monster has a name, a statblock, and a list of attacks.
    class Monster
      attr_reader :name, :statblock, :attacks
      attr_accessor :team

      # Initializes a new Monster.
      #
      # @param name [String] The name of the monster.
      # @param statblock [Statblock] The monster's statblock.
      # @param attacks [Array<Attack>] The monster's attacks.
      # @param team [Object, nil] The team the monster belongs to.
      def initialize(name:, statblock:, attacks: [], team: nil)
        @name = name
        @statblock = statblock
        @attacks = attacks
        @team = team
      end
    end
  end
end
