# frozen_string_literal: true

module Dnd5e
  module Builders
    # Builder methods for caster classes.
    module CasterClassMethods
      def as_cleric(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:cleric, level, abilities)
        with_attack(Core::Attack.new(name: 'Mace', damage_dice: Core::Dice.new(1, 6), relevant_stat: :strength))
        add_cleric_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_bard(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:bard, level, abilities)
        with_attack(Core::Attack.new(name: 'Rapier', damage_dice: Core::Dice.new(1, 8), relevant_stat: :dexterity))
        add_bard_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_druid(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:druid, level, abilities)
        with_attack(Core::Attack.new(name: 'Scimitar', damage_dice: Core::Dice.new(1, 6), relevant_stat: :dexterity))
        add_druid_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_sorcerer(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:sorcerer, level, abilities)
        with_attack(Core::Attack.new(name: 'Firebolt', damage_dice: Core::Dice.new(1, 10), relevant_stat: :charisma,
                                     type: :attack, scaling: true, range: 120))
        add_sorcerer_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_warlock(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:warlock, level, abilities)
        with_attack(Core::Attack.new(name: 'Eldritch Blast', damage_dice: Core::Dice.new(1, 10),
                                     relevant_stat: :charisma, type: :attack, scaling: true, range: 120))
        add_warlock_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_wizard(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:wizard, level, abilities)
        add_wizard_equipment
        with_subclass(subclass, level: level) if subclass
        self
      end
    end
  end
end
