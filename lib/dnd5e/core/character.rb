require_relative "statblock"
module Dnd5e
  module Core
    class Character
      attr_reader :name, :statblock
      def initialize(name:, statblock:)
        @name = name
        @statblock = statblock
      end
    end
  end
end
