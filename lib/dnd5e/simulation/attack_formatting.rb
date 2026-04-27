# frozen_string_literal: true

module Dnd5e
  module Simulation
    # Logic for formatting attack events in JSON results.
    module AttackFormatting
      private

      def format_attack_event(res)
        base = { type: res.type, attacker: res.attacker.name, defender: res.defender.name,
                 attack_name: res.attack.name, success: res.success }
        base.merge(damage: res.damage, is_crit: res.is_crit, is_dead: res.is_dead,
                   metadata: extract_metadata(res))
      end

      def extract_metadata(res)
        { attack_roll: res.attack_roll, picked_roll: res.raw_roll, raw_rolls: res.rolls,
          modifier: res.modifier, proficiency_bonus: res.proficiency_bonus,
          target_ac: res.target_ac, damage_rolls: res.damage_rolls,
          damage_modifier: res.damage_modifier, current_hp: res.current_hp,
          max_hp: res.max_hp, save_roll: res.save_roll, save_dc: res.save_dc,
          maneuver: res.respond_to?(:maneuver) ? res.maneuver : nil }
      end
    end
  end
end
