# frozen_string_literal: true

module Dnd5e
  module Core
    module Strategies
      # Extra attack logic for SimpleStrategy.
      module ExtraAttackHelper
        private

        # rubocop:disable Metrics/MethodLength
        def try_extra_attacks(combatant, target, attack, combat)
          target = ensure_alive_target(combatant, target, combat)
          return unless target

          try_nick_attack(combatant, target, combat)
          target = ensure_alive_target(combatant, target, combat)
          return unless target

          try_horde_breaker_attack(combatant, target, attack, combat)
          target = ensure_alive_target(combatant, target, combat)
          return unless target

          try_dual_wielder_attack(combatant, target, combat)
          target = ensure_alive_target(combatant, target, combat)
          return unless target

          try_gwm_bonus_attack(combatant, target, attack, combat)
        end
        # rubocop:enable Metrics/MethodLength

        def try_horde_breaker_attack(combatant, target, attack, combat)
          return if combatant.turn_context.flags[:horde_breaker_used]
          return unless combatant.feature_manager.features.any? { |f| f.name == 'Horde Breaker' }

          # Find a different target within 5ft of the original target
          target_pos = combat.grid.find_position(target)
          return unless target_pos

          new_target = find_adjacent_enemy(combatant, target, target_pos, combat)
          return unless new_target

          combatant.turn_context.flags[:horde_breaker_used] = true
          combat.attack(combatant, new_target, attack: attack)
        end

        def ensure_alive_target(combatant, target, combat)
          target&.statblock&.alive? ? target : find_target(combatant, combat)
        end

        def try_cleave_attack(combatant, target, attack, combat)
          return unless attack.mastery == :cleave && !combatant.turn_context.flags[:cleave_used]

          # Cleave: Make another attack against a different target within 5ft
          target_pos = combat.grid.find_position(target)
          return unless target_pos

          new_target = find_adjacent_enemy(combatant, target, target_pos, combat)
          return unless new_target

          combatant.turn_context.flags[:cleave_used] = true
          combat.attack(combatant, new_target, attack: attack)
        end

        def find_adjacent_enemy(combatant, target, target_pos, combat)
          combat.combatants.find do |c|
            next if c == target || c == combatant || !c.statblock.alive? || !combat.enemy?(combatant, c)

            c_pos = combat.grid.find_position(c)
            c_pos && combat.grid.distance(target_pos, c_pos) <= 5
          end
        end

        def try_nick_attack(combatant, target, combat)
          return if combatant.turn_context.nick_used

          nick_weapon = combatant.attacks.find { |a| a.mastery == :nick }
          return unless nick_weapon

          combatant.turn_context.instance_variable_set(:@nick_used, true)
          combat.attack(combatant, target, attack: nick_weapon)
        end

        def try_dual_wielder_attack(combatant, target, combat)
          return unless combatant.feature_manager.features.any? { |f| f.name == 'Dual Wielder' }
          return unless combatant.turn_context.bonus_action_available?

          light_weapon = combatant.attacks.find { |a| a.properties.include?(:light) }
          return unless light_weapon

          combatant.turn_context.use_bonus_action
          combat.attack(combatant, target, attack: light_weapon, offhand: true)
        end

        # rubocop:disable Metrics/AbcSize
        def try_gwm_bonus_attack(combatant, target, _attack, combat)
          return unless combatant.feature_manager.features.any? { |f| f.name == 'Great Weapon Master' }
          return unless combatant.turn_context.bonus_action_available?
          return unless combatant.turn_context.flags[:gwm_bonus_available]

          heavy_weapon = combatant.attacks.find { |a| a.properties.include?(:heavy) }
          return unless heavy_weapon

          combatant.turn_context.flags[:gwm_bonus_available] = false
          combatant.turn_context.use_bonus_action
          combat.attack(combatant, target, attack: heavy_weapon)
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
