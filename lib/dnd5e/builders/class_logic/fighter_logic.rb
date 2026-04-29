# frozen_string_literal: true

module Dnd5e
  module Builders
    module ClassLogic
      # Logic for building Fighter characters.
      module FighterLogic
        private

        def build_fighter_statblock(level, abilities, armor_type: :heavy)
          Core::Statblock.new(
            name: @name, strength: abilities[:strength], dexterity: abilities[:dexterity],
            constitution: abilities[:constitution], intelligence: abilities[:intelligence],
            wisdom: abilities[:wisdom], charisma: abilities[:charisma], hit_die: 'd10',
            level: level, hit_points: calculate_hp(level, abilities),
            saving_throw_proficiencies: %i[strength constitution],
            equipped_armor: create_armor(armor_type), extra_attacks: (level >= 5 ? 1 : 0),
            resources: calculate_fighter_resources(level)
          )
        end

        def calculate_hp(level, abilities)
          con_mod = (abilities[:constitution] - 10) / 2
          10 + con_mod + ((6 + con_mod) * (level - 1))
        end

        def calculate_fighter_resources(level)
          {
            second_wind: calculate_second_wind(level),
            action_surge: (level >= 17 ? 2 : 1)
          }
        end

        def calculate_second_wind(level)
          if level >= 10 then 4
          elsif level >= 6 then 3
          else 2
          end
        end
      end
    end
  end
end
