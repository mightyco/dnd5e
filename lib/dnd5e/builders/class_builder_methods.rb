# frozen_string_literal: true

module Dnd5e
  module Builders
    # Separate module for individual class methods to keep CharacterBuilder small.
    # rubocop:disable Metrics/ModuleLength
    module ClassBuilderMethods
      def as_rogue(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:rogue, level, abilities)
        add_rogue_equipment
        add_rogue_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_barbarian(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:barbarian, level, abilities)
        with_attack(Core::Attack.new(name: 'Greataxe', damage_dice: Core::Dice.new(1, 12), relevant_stat: :strength))
        add_barbarian_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_paladin(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:paladin, level, abilities)
        with_attack(Core::Attack.new(name: 'Longsword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength))
        add_paladin_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_monk(level: 1, abilities: {})
        add_class_levels(:monk, level, abilities)
        with_attack(Core::Attack.new(name: 'Unarmed Strike', damage_dice: Core::Dice.new(1, 6),
                                     relevant_stat: :dexterity))
        add_monk_features(level)
        self
      end

      def as_ranger(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:ranger, level, abilities)
        with_attack(Core::Attack.new(name: 'Longbow', damage_dice: Core::Dice.new(1, 8),
                                     relevant_stat: :dexterity, range: 150, properties: [:ranged]))
        add_ranger_features(level)
        with_subclass(subclass, level: level) if subclass
        self
      end

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

      def as_fighter(level: 1, abilities: {}, armor_type: :heavy, subclass: nil)
        add_class_levels(:fighter, level, abilities, armor_type: armor_type)
        with_attack(Core::Attack.new(name: 'Longsword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength))
        with_feature(Core::Features::ActionSurge.new) if level >= 2
        with_feature(Core::Features::SecondWind.new) if level >= 1
        with_subclass(subclass, level: level) if subclass
        self
      end

      def as_wizard(level: 1, abilities: {}, subclass: nil)
        add_class_levels(:wizard, level, abilities)
        add_wizard_equipment
        with_subclass(subclass, level: level) if subclass
        self
      end

      private

      def add_class_levels(class_name, level, abilities, **opts)
        abilities = merge_abilities(abilities)
        if @statblock
          level.times { @statblock.level_up(class_name) }
          @statblock.resources = Core::ResourcePool.new(recalculate_all_resources)
        else
          method_name = "build_#{class_name}_statblock"
          @statblock = opts.any? ? send(method_name, level, abilities, **opts) : send(method_name, level, abilities)
        end
      end

      def recalculate_all_resources
        levels = @statblock.class_levels
        if levels.size > 1
          SpellSlotCalculator.calculate_multiclass(levels).merge(calculate_class_resources(levels))
        else
          @statblock.resources.resources
        end
      end

      def calculate_class_resources(levels)
        res = {}
        res.merge!(calculate_fighter_resources(levels[:fighter])) if levels[:fighter]
        res
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
