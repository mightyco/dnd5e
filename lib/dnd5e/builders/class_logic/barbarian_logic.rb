# frozen_string_literal: true

module Dnd5e
  module Builders
    module ClassLogic
      # Logic for building Barbarian characters.
      module BarbarianLogic
        private

        def build_barbarian_statblock(level, abilities)
          Core::Statblock.new(
            name: @name, strength: abilities[:strength], dexterity: abilities[:dexterity],
            constitution: abilities[:constitution], intelligence: abilities[:intelligence],
            wisdom: abilities[:wisdom], charisma: abilities[:charisma], hit_die: 'd12',
            level: level, saving_throw_proficiencies: %i[strength constitution],
            equipped_armor: nil, # Unarmored Defense
            extra_attacks: (level >= 5 ? 1 : 0),
            resources: { rage: calculate_rage_uses(level) }
          )
        end

        def calculate_rage_uses(level)
          if level >= 17 then 6
          elsif level >= 12 then 5
          elsif level >= 6 then 4
          elsif level >= 3 then 3
          else 2
          end
        end

        def add_barbarian_features(level)
          with_feature(Core::Features::Rage.new(damage_bonus: (level >= 9 ? 3 : 2)))
          with_feature(Core::Features::RecklessAttack.new) if level >= 2
          @subclass_strategy = Core::Strategies::BarbarianStrategy.new
        end
      end
    end
  end
end
