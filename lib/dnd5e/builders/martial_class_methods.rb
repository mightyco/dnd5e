# frozen_string_literal: true

module Dnd5e
  module Builders
    # Builder methods for martial classes.
    module MartialClassMethods
      def as_rogue(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:rogue, level, abilities)
        add_rogue_equipment
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_barbarian(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:barbarian, level, abilities)
        with_attack(Core::Attack.new(name: 'Greataxe', damage_dice: Core::Dice.new(1, 12), relevant_stat: :strength))
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_paladin(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:paladin, level, abilities)
        with_attack(Core::Attack.new(name: 'Longsword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength))
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_monk(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:monk, level, abilities)
        with_attack(Core::Attack.new(name: 'Unarmed Strike', damage_dice: Core::Dice.new(1, 6),
                                     relevant_stat: :dexterity))
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_ranger(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:ranger, level, abilities)
        with_attack(Core::Attack.new(name: 'Longbow', damage_dice: Core::Dice.new(1, 8),
                                     relevant_stat: :dexterity, range: 150, properties: [:ranged]))
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_fighter(level: 1, abilities: {}, armor_type: :heavy, subclass: nil)
        add_class_levels(:fighter, level, abilities, armor_type: armor_type)
        with_attack(Core::Attack.new(name: 'Longsword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength))
        with_feature(Core::Features::ActionSurge.new) if level >= 2
        with_feature(Core::Features::SecondWind.new) if level >= 1
        with_subclass(subclass, level: level) if subclass
        self
      end
    end
  end
end
