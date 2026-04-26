# frozen_string_literal: true

module Dnd5e
  module Builders
    module ClassLogic
      # Logic for building Ranger characters.
      module RangerLogic
        private

        def build_ranger_statblock(level, abilities)
          resources = SpellSlotCalculator.calculate('Ranger', level)
          Core::Statblock.new(
            name: @name, strength: abilities[:strength], dexterity: abilities[:dexterity],
            constitution: abilities[:constitution], intelligence: abilities[:intelligence],
            wisdom: abilities[:wisdom], charisma: abilities[:charisma], hit_die: 'd10',
            level: level, saving_throw_proficiencies: %i[strength dexterity],
            equipped_armor: create_armor(:medium),
            extra_attacks: (level >= 5 ? 1 : 0),
            resources: resources
          )
        end

        def add_ranger_features(_level)
          with_feature(Core::Features::HuntersMark.new)
          @subclass_strategy = Core::Strategies::RangerStrategy.new
        end
      end
    end
  end
end
