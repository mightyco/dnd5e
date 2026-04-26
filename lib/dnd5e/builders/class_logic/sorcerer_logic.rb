# frozen_string_literal: true

module Dnd5e
  module Builders
    module ClassLogic
      # Logic for building Sorcerer characters.
      module SorcererLogic
        private

        def build_sorcerer_statblock(level, abilities)
          resources = SpellSlotCalculator.calculate('Sorcerer', level)
          resources[:sorcery_points] = (level >= 2 ? level : 0)
          Core::Statblock.new(
            name: @name, strength: abilities[:strength], dexterity: abilities[:dexterity],
            constitution: abilities[:constitution], intelligence: abilities[:intelligence],
            wisdom: abilities[:wisdom], charisma: abilities[:charisma], hit_die: 'd6',
            level: level, saving_throw_proficiencies: %i[constitution charisma],
            resources: resources
          )
        end

        def add_sorcerer_features(_level)
          with_feature(Core::Features::InnateSorcery.new)
          @subclass_strategy = Core::Strategies::SorcererStrategy.new
        end
      end
    end
  end
end
