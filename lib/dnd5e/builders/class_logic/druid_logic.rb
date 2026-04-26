# frozen_string_literal: true

module Dnd5e
  module Builders
    module ClassLogic
      # Logic for building Druid characters.
      module DruidLogic
        private

        def build_druid_statblock(level, abilities)
          resources = SpellSlotCalculator.calculate('Druid', level)
          resources[:wild_shape] = (level >= 1 ? 2 : 0)
          Core::Statblock.new(
            name: @name, strength: abilities[:strength], dexterity: abilities[:dexterity],
            constitution: abilities[:constitution], intelligence: abilities[:intelligence],
            wisdom: abilities[:wisdom], charisma: abilities[:charisma], hit_die: 'd8',
            level: level, saving_throw_proficiencies: %i[intelligence wisdom],
            equipped_armor: create_armor(:medium),
            resources: resources
          )
        end

        def add_druid_features(_level)
          with_feature(Core::Features::WildShape.new)
          @subclass_strategy = Core::Strategies::DruidStrategy.new
        end
      end
    end
  end
end
