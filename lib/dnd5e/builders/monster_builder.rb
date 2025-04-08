module Dnd5e
  module Builders
    class MonsterBuilder
      class InvalidMonsterError < StandardError; end

      def initialize(name:)
        @name = name
        @statblock = nil
        @attacks = []
      end

      def with_statblock(statblock)
        @statblock = statblock
        self
      end

      def with_attack(attack)
        @attacks << attack
        self
      end

      def build
        raise InvalidMonsterError, "Monster must have a name" if @name.nil? || @name.empty?
        raise InvalidMonsterError, "Monster must have a statblock" if @statblock.nil?

        Core::Monster.new(name: @name, statblock: @statblock, attacks: @attacks)
      end
    end
  end
end
