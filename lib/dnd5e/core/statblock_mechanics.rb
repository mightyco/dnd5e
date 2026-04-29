# frozen_string_literal: true

module Dnd5e
  module Core
    # Action mechanics for Statblock (damage, healing, etc).
    module StatblockMechanics
      def ability_modifier(ability)
        unless %i[strength dexterity constitution intelligence wisdom charisma].include?(ability)
          raise ArgumentError, "Invalid ability: #{ability}"
        end

        score = send(ability)
        (score - 10) / 2
      end

      def proficient_in_save?(ability)
        @saving_throw_proficiencies.include?(ability)
      end

      def save_modifier(ability)
        mod = ability_modifier(ability)
        mod += proficiency_bonus if proficient_in_save?(ability)
        mod
      end

      def take_damage(damage)
        raise ArgumentError, 'Damage must be non-negative' if damage.negative?

        @hit_points = [0, @hit_points - damage].max
        @damage_taken += damage
      end

      def record_damage_dealt(damage)
        @damage_dealt += damage
      end

      def heal(amount)
        raise ArgumentError, 'Healing amount must be non-negative' if amount.negative?

        @hit_points = [@max_hp, @hit_points + amount].min
      end

      def alive?
        @hit_points.positive?
      end

      def proficiency_bonus
        Proficiency.calculate(level)
      end

      private

      def unarmored_class?
        @class_levels&.key?(:monk) || @class_levels&.key?(:barbarian)
      end

      def calculate_unarmored_ac
        dex_mod = ability_modifier(:dexterity)
        if @class_levels&.key?(:monk)
          10 + dex_mod + ability_modifier(:wisdom)
        else
          10 + dex_mod + ability_modifier(:constitution)
        end
      end

      def calculate_base_ac
        dex_mod = ability_modifier(:dexterity)
        base_ac = defined?(@base_ac_override) ? @base_ac_override : 10
        @equipped_armor ? @equipped_armor.calculate_ac(dex_mod) : base_ac + dex_mod
      end
    end
  end
end
