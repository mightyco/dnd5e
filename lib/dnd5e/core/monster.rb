require_relative "statblock"
require_relative "attack"

module Dnd5e
  module Core
    class Monster
      attr_reader :name, :statblock, :attacks
      attr_accessor :team

      def initialize(name:, statblock:, attacks: [], team: nil)
        @name = name
        @statblock = statblock
        @attacks = attacks
        @team = team
      end
    end
  end
end
