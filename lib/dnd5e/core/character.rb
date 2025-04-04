require_relative "statblock"
require_relative "attack"

module Dnd5e
  module Core
    class Character
      attr_reader :name, :statblock, :attacks

      def initialize(name:, statblock:, attacks: [])
        @name = name
        @statblock = statblock
        @attacks = attacks
      end
    end
  end
end
