require_relative "statblock"
require_relative "attack"

module Dnd5e
  module Core
    class Monster < Statblock
      attr_reader :attacks

      def initialize(name:, strength: 10, dexterity: 10, constitution: 10, intelligence: 10, wisdom: 10, charisma: 10, hit_die: "d8", level: 1, attacks: [])
        super(name: name, strength: strength, dexterity: dexterity, constitution: constitution, intelligence: intelligence, wisdom: wisdom, charisma: charisma, hit_die: hit_die, level: level)
        @attacks = attacks
      end
    end
  end
end
