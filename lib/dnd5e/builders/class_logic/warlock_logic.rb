# frozen_string_literal: true

module Dnd5e
  module Builders
    module ClassLogic
      # Logic for building Warlock characters.
      module WarlockLogic
        private

        def build_warlock_statblock(level, abilities)
          resources = SpellSlotCalculator.calculate('Warlock', level)
          Core::Statblock.new(
            name: @name, strength: abilities[:strength], dexterity: abilities[:dexterity],
            constitution: abilities[:constitution], intelligence: abilities[:intelligence],
            wisdom: abilities[:wisdom], charisma: abilities[:charisma], hit_die: 'd8',
            level: level, saving_throw_proficiencies: %i[wisdom charisma],
            equipped_armor: create_armor(:light),
            resources: resources
          )
        end

        def add_warlock_features(level)
          with_feature(Core::Features::AgonizingBlast.new) if level >= 2
          @subclass_strategy = Core::Strategies::WarlockStrategy.new
        end
      end
    end
  end
end
