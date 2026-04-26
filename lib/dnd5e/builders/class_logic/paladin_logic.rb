# frozen_string_literal: true

module Dnd5e
  module Builders
    module ClassLogic
      # Logic for building Paladin characters.
      module PaladinLogic
        private

        def build_paladin_statblock(level, abilities)
          Core::Statblock.new(
            name: @name, strength: abilities[:strength], dexterity: abilities[:dexterity],
            constitution: abilities[:constitution], intelligence: abilities[:intelligence],
            wisdom: abilities[:wisdom], charisma: abilities[:charisma], hit_die: 'd10',
            level: level, saving_throw_proficiencies: %i[wisdom charisma],
            equipped_armor: create_armor(:heavy),
            extra_attacks: (level >= 5 ? 1 : 0),
            resources: calculate_paladin_resources(level)
          )
        end

        def calculate_paladin_resources(level)
          resources = SpellSlotCalculator.calculate('Paladin', level)
          resources[:channel_divinity] = (level >= 3 ? 2 : 0)
          resources
        end

        def add_paladin_features(level)
          with_feature(Core::Features::DivineSmite.new) if level >= 2
          @subclass_strategy = Core::Strategies::PaladinStrategy.new
        end
      end
    end
  end
end
