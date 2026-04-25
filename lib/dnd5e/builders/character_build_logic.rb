# frozen_string_literal: true

module Dnd5e
  module Builders
    # Specific build logic for different classes.
    module ClassBuildLogic
      private

      def build_fighter_statblock(level, abilities, armor_type)
        Core::Statblock.new(
          name: @name, strength: abilities[:strength], dexterity: abilities[:dexterity],
          constitution: abilities[:constitution], intelligence: abilities[:intelligence],
          wisdom: abilities[:wisdom], charisma: abilities[:charisma], hit_die: 'd10',
          level: level, saving_throw_proficiencies: %i[strength constitution],
          equipped_armor: create_armor(armor_type), extra_attacks: (level >= 5 ? 1 : 0),
          resources: calculate_fighter_resources(level)
        )
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
