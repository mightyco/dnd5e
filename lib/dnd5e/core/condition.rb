# frozen_string_literal: true

module Dnd5e
  module Core
    # Represents a status condition (e.g., Prone, Grappled).
    class Condition
      attr_reader :name, :description, :mechanics

      # @param name [Symbol] The name of the condition.
      # @param description [String] Text description of the condition.
      # @param mechanics [Hash] Structured mechanical effects.
      def initialize(name:, description: '', mechanics: {})
        @name = name
        @description = description
        @mechanics = mechanics
      end

      # Standard Conditions Definitions
      DEFINITIONS = {
        prone: {
          description: 'A prone creature’s only movement option is to crawl. The creature has Disadvantage on ' \
                       'Attack Rolls. An Attack Roll against the creature has Advantage if the attacker is ' \
                       'within 5 feet of the creature. Otherwise, the Attack Roll has Disadvantage.',
          mechanics: {
            disadvantage_on_attacks: true,
            grant_advantage_melee: true,
            grant_disadvantage_ranged: true # Simplified: assuming range > 5ft is ranged weapon
          }
        },
        grappled: {
          description: 'A grappled creature’s speed becomes 0, and it can’t benefit from any bonus to its speed.',
          mechanics: {
            speed: 0
          }
        },
        restrained: {
          description: 'A restrained creature’s speed becomes 0. Attack Rolls against the creature have Advantage, ' \
                       'and the creature’s Attack Rolls have Disadvantage. The creature has Disadvantage on ' \
                       'Dexterity Saving Throws.',
          mechanics: {
            speed: 0,
            grant_advantage_on_attacks: true,
            disadvantage_on_attacks: true,
            disadvantage_on_dex_saves: true
          }
        },
        hidden: {
          description: 'A hidden creature is unseen and unheard. Attack rolls against it have Disadvantage ' \
                       '(if you can guess location), and it has Advantage on attack rolls.',
          mechanics: {
            grant_disadvantage_on_attacks: true,
            advantage_on_attacks: true
          }
        }
      }.freeze

      def self.new_from_name(name)
        def_data = DEFINITIONS[name]
        raise ArgumentError, "Unknown condition: #{name}" unless def_data

        new(name: name, description: def_data[:description], mechanics: def_data[:mechanics])
      end
    end
  end
end
