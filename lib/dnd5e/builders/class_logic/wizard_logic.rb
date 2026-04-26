# frozen_string_literal: true

module Dnd5e
  module Builders
    module ClassLogic
      # Logic for building Wizard characters.
      module WizardLogic
        private

        def build_wizard_statblock(level, abilities)
          resources = SpellSlotCalculator.calculate('Wizard', level)
          Core::Statblock.new(
            name: @name,
            strength: abilities[:strength], dexterity: abilities[:dexterity], constitution: abilities[:constitution],
            intelligence: abilities[:intelligence], wisdom: abilities[:wisdom], charisma: abilities[:charisma],
            hit_die: 'd6', level: level, saving_throw_proficiencies: %i[intelligence wisdom],
            resources: resources
          )
        end
      end
    end
  end
end
