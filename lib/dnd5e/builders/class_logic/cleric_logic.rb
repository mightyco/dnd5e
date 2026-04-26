# frozen_string_literal: true

module Dnd5e
  module Builders
    module ClassLogic
      # Logic for building Cleric characters.
      module ClericLogic
        private

        def build_cleric_statblock(level, abilities)
          resources = SpellSlotCalculator.calculate('Cleric', level)
          resources[:channel_divinity] = (level >= 1 ? 2 : 0)
          Core::Statblock.new(
            name: @name, strength: abilities[:strength], dexterity: abilities[:dexterity],
            constitution: abilities[:constitution], intelligence: abilities[:intelligence],
            wisdom: abilities[:wisdom], charisma: abilities[:charisma], hit_die: 'd8',
            level: level, saving_throw_proficiencies: %i[wisdom charisma],
            equipped_armor: create_armor(:medium),
            resources: resources
          )
        end

        def add_cleric_features(_level)
          with_feature(Core::Features::DivineSpark.new)
          @subclass_strategy = Core::Strategies::ClericStrategy.new
        end
      end
    end
  end
end
