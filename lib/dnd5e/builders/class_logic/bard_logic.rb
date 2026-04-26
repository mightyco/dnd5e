# frozen_string_literal: true

module Dnd5e
  module Builders
    module ClassLogic
      # Logic for building Bard characters.
      module BardLogic
        private

        def build_bard_statblock(level, abilities)
          resources = SpellSlotCalculator.calculate('Bard', level)
          resources[:bardic_inspiration] = (level >= 1 ? 4 : 0)
          Core::Statblock.new(
            name: @name, strength: abilities[:strength], dexterity: abilities[:dexterity],
            constitution: abilities[:constitution], intelligence: abilities[:intelligence],
            wisdom: abilities[:wisdom], charisma: abilities[:charisma], hit_die: 'd8',
            level: level, saving_throw_proficiencies: %i[dexterity charisma],
            equipped_armor: create_armor(:light),
            resources: resources
          )
        end

        def add_bard_features(_level)
          with_feature(Core::Features::BardicInspiration.new)
          @subclass_strategy = Core::Strategies::BardStrategy.new
        end
      end
    end
  end
end
