# frozen_string_literal: true

module Dnd5e
  module Builders
    module ClassLogic
      # Logic for building Rogue characters.
      module RogueLogic
        private

        def build_rogue_statblock(level, abilities)
          Core::Statblock.new(
            name: @name,
            strength: abilities[:strength], dexterity: abilities[:dexterity],
            constitution: abilities[:constitution], intelligence: abilities[:intelligence],
            wisdom: abilities[:wisdom], charisma: abilities[:charisma],
            hit_die: 'd8', level: level, saving_throw_proficiencies: %i[dexterity intelligence],
            equipped_armor: create_armor(:light)
          )
        end

        def add_rogue_equipment
          shortsword = Core::Attack.new(name: 'Shortsword', damage_dice: Core::Dice.new(1, 6),
                                        relevant_stat: :dexterity, properties: %i[finesse light])
          shortbow = Core::Attack.new(name: 'Shortbow', damage_dice: Core::Dice.new(1, 6),
                                      relevant_stat: :dexterity, range: 80, properties: [:ranged])
          with_attack(shortsword)
          with_attack(shortbow)
        end

        def add_rogue_features(level)
          sa_dice = (level + 1) / 2
          with_feature(Core::Features::SneakAttack.new(dice_count: sa_dice))
          with_feature(Core::Features::CunningAction.new) if level >= 2
          with_feature(Core::Features::Evasion.new) if level >= 7
          @subclass_strategy = Core::Strategies::RogueStrategy.new
        end
      end
    end
  end
end
