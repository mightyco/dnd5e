# frozen_string_literal: true

require_relative '../core/monster'
require_relative '../core/statblock'
require_relative '../core/attack'
require_relative '../core/dice'

module Dnd5e
  module Builders
    # Builds a Monster object with a fluent interface.
    #
    # @see Dnd5e::Builders
    class MonsterBuilder
      # Error raised when an invalid monster is built.
      class InvalidMonsterError < StandardError; end

      # Initializes a new MonsterBuilder.
      #
      # @param name [String] The name of the monster.
      def initialize(name:)
        @name = name
        @statblock = nil
        @attacks = []
      end

      # Sets the statblock for the monster.
      #
      # @param statblock [Statblock] The statblock for the monster.
      # @return [MonsterBuilder] The MonsterBuilder instance.
      def with_statblock(statblock)
        @statblock = statblock
        self
      end

      # Adds an attack to the monster.
      #
      # @param attack [Attack] The attack to add.
      # @return [MonsterBuilder] The MonsterBuilder instance.
      def with_attack(attack)
        @attacks << attack
        self
      end

      # Builds the monster as a Goblin.
      #
      # @return [MonsterBuilder] The MonsterBuilder instance.
      def as_goblin
        @statblock = Core::Statblock.new(
          name: @name,
          strength: 8, dexterity: 14, constitution: 10,
          intelligence: 10, wisdom: 8, charisma: 8,
          hit_die: 'd6', level: 1, saving_throw_proficiencies: []
        )

        scimitar = Core::Attack.new(name: 'Scimitar', damage_dice: Core::Dice.new(1, 6), relevant_stat: :dexterity)
        with_attack(scimitar)
        self
      end

      # Builds the monster.
      #
      # @return [Monster] The built monster.
      # @raise [InvalidMonsterError] if the monster is invalid.
      def build
        raise InvalidMonsterError, 'Monster must have a name' if @name.nil? || @name.empty?
        raise InvalidMonsterError, 'Monster must have a statblock' if @statblock.nil?

        Core::Monster.new(name: @name, statblock: @statblock, attacks: @attacks)
      end
    end
  end
end
