# frozen_string_literal: true

module Dnd5e
  module Builders
    # Separate module for individual class methods to keep CharacterBuilder small.
    module ClassBuilderMethods
      def as_rogue(level: 1, abilities: {}, subclass: nil)
        abilities = merge_abilities(abilities)
        @statblock = build_rogue_statblock(level, abilities)
        add_rogue_equipment
        add_rogue_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_barbarian(level: 1, abilities: {}, subclass: nil)
        abilities = merge_abilities(abilities)
        @statblock = build_barbarian_statblock(level, abilities)
        with_attack(Core::Attack.new(name: 'Greataxe', damage_dice: Core::Dice.new(1, 12), relevant_stat: :strength))
        add_barbarian_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_paladin(level: 1, abilities: {}, subclass: nil)
        abilities = merge_abilities(abilities)
        @statblock = build_paladin_statblock(level, abilities)
        with_attack(Core::Attack.new(name: 'Longsword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength))
        add_paladin_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_monk(level: 1, abilities: {})
        abilities = merge_abilities(abilities)
        @statblock = build_monk_statblock(level, abilities)
        with_attack(Core::Attack.new(name: 'Unarmed Strike', damage_dice: Core::Dice.new(1, 6),
                                     relevant_stat: :dexterity))
        add_monk_features(level)
        self
      end

      def as_ranger(level: 1, abilities: {}, subclass: nil)
        abilities = merge_abilities(abilities)
        @statblock = build_ranger_statblock(level, abilities)
        with_attack(Core::Attack.new(name: 'Longbow', damage_dice: Core::Dice.new(1, 8),
                                     relevant_stat: :dexterity, range: 150, properties: [:ranged]))
        add_ranger_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_cleric(level: 1, abilities: {}, subclass: nil)
        abilities = merge_abilities(abilities)
        @statblock = build_cleric_statblock(level, abilities)
        with_attack(Core::Attack.new(name: 'Mace', damage_dice: Core::Dice.new(1, 6), relevant_stat: :strength))
        add_cleric_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_bard(level: 1, abilities: {}, subclass: nil)
        abilities = merge_abilities(abilities)
        @statblock = build_bard_statblock(level, abilities)
        with_attack(Core::Attack.new(name: 'Rapier', damage_dice: Core::Dice.new(1, 8), relevant_stat: :dexterity))
        add_bard_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_druid(level: 1, abilities: {}, subclass: nil)
        abilities = merge_abilities(abilities)
        @statblock = build_druid_statblock(level, abilities)
        with_attack(Core::Attack.new(name: 'Scimitar', damage_dice: Core::Dice.new(1, 6), relevant_stat: :dexterity))
        add_druid_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_sorcerer(level: 1, abilities: {}, subclass: nil)
        abilities = merge_abilities(abilities)
        @statblock = build_sorcerer_statblock(level, abilities)
        with_attack(Core::Attack.new(name: 'Firebolt', damage_dice: Core::Dice.new(1, 10), relevant_stat: :charisma,
                                     type: :attack, scaling: true, range: 120))
        add_sorcerer_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_warlock(level: 1, abilities: {}, subclass: nil)
        abilities = merge_abilities(abilities)
        @statblock = build_warlock_statblock(level, abilities)
        with_attack(Core::Attack.new(name: 'Eldritch Blast', damage_dice: Core::Dice.new(1, 10),
                                     relevant_stat: :charisma, type: :attack, scaling: true, range: 120))
        add_warlock_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_fighter(level: 1, abilities: {}, armor_type: :heavy, subclass: nil)
        abilities = merge_abilities(abilities)
        @statblock = build_fighter_statblock(level, abilities, armor_type)
        with_attack(Core::Attack.new(name: 'Longsword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength))
        with_feature(Core::Features::ActionSurge.new) if level >= 2
        with_feature(Core::Features::SecondWind.new) if level >= 1
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_wizard(level: 1, abilities: {}, subclass: nil)
        abilities = merge_abilities(abilities)
        @statblock = build_wizard_statblock(level, abilities)
        add_wizard_equipment
        with_subclass(subclass, level: level) if subclass
        self
      end
    end
  end
end
