# frozen_string_literal: true

require_relative '../helpers/pathfinder'

module Dnd5e
  module Core
    module Strategies
      # Extra attack logic for SimpleStrategy.
      module ExtraAttackHelper
        private

        def try_extra_attacks(combatant, target, attack, combat)
          target = ensure_alive_target(combatant, target, combat)
          return unless target

          try_nick_attack(combatant, target, combat)
          target = ensure_alive_target(combatant, target, combat)
          return unless target

          try_dual_wielder_attack(combatant, target, combat)
          target = ensure_alive_target(combatant, target, combat)
          return unless target

          try_gwm_bonus_attack(combatant, target, attack, combat)
        end

        def ensure_alive_target(combatant, target, combat)
          target&.statblock&.alive? ? target : find_target(combatant, combat)
        end

        def try_cleave_attack(combatant, target, attack, combat)
          return unless attack.mastery == :cleave && !target.statblock.alive?

          new_target = (combat.combatants - [combatant, target]).find { |c| c.statblock.alive? }
          combat.attack(combatant, new_target, attack: attack) if new_target
        end

        def try_gwm_bonus_attack(combatant, target, attack, combat)
          return unless combatant.feature_manager.features.any? { |f| f.name == 'Great Weapon Master' }
          return unless !target.statblock.alive? && combatant.turn_context.bonus_action_available?

          new_target = target.statblock.alive? ? target : combat.find_valid_defender(combatant)
          return unless new_target

          combat.attack(combatant, new_target, attack: attack)
          combatant.turn_context.use_bonus_action
        end

        def try_nick_attack(combatant, target, combat)
          return unless combatant.turn_context.nick_available? && target.statblock.alive?

          nick_weapon = combatant.attacks.find { |a| a.properties.include?(:light) && a.mastery == :nick }
          return unless nick_weapon

          combat.attack(combatant, target, attack: nick_weapon, offhand: true)
          combatant.turn_context.use_nick
        end

        def try_dual_wielder_attack(combatant, target, combat)
          return unless target.statblock.alive? && combatant.turn_context.bonus_action_available?
          return unless combatant.feature_manager.features.any? { |f| f.name == 'Dual Wielder' }

          light_weapon = combatant.attacks.find { |a| a.properties.include?(:light) }
          return unless light_weapon

          combat.attack(combatant, target, attack: light_weapon, offhand: true)
          combatant.turn_context.use_bonus_action
        end
      end

      # Helper logic for SimpleStrategy to keep the main class small.
      module SimpleStrategyLogic
        include ExtraAttackHelper

        private

        def move_towards_target(combatant, target, attack, combat)
          return unless combatant.turn_context.movement_available?.positive?
          return if in_range?(combatant, target, attack, combat) && !should_kite?(combatant, target, combat)

          target_pos = combat.grid.find_position(target)
          current_pos = combat.grid.find_position(combatant)
          return unless target_pos && current_pos

          execute_grid_move(combatant, current_pos, target_pos, combatant.turn_context.movement_available?, combat)
        end

        def execute_grid_move(combatant, _cur_pos, target_pos, speed, combat)
          path = Helpers::Pathfinder.new(combat.grid).find_path(combat.grid.find_position(combatant), target_pos)
          if path.empty?
            combatant.turn_context.use_movement(speed)
            return
          end

          trim_path_for_occupancy(path, target_pos, combat.grid)
          apply_move_segment(combatant, path, speed, combat)
        end

        def trim_path_for_occupancy(path, target_pos, grid)
          path.pop if path.last == target_pos && grid.occupied?(target_pos)
        end

        def apply_move_segment(combatant, path, speed, combat)
          max_sq = speed / 5
          segment = path[0...max_sq]
          return if segment.empty?

          combat.move_combatant(combatant, segment)
          combatant.turn_context.use_movement(segment.size * 5)
        end

        def should_kite?(combatant, target, combat)
          dist = combat.grid.distance(combatant, target)
          dist <= 5 && combatant.attacks.any? { |a| a.range > 5 }
        end

        def in_range?(combatant, target, attack, combat)
          return false unless target

          combat.grid.distance(combatant, target) <= attack.range
        end

        def execute_attacks(combatant, target, attack, combat)
          num_attacks = attack.type == :save ? 1 : 1 + combatant.statblock.extra_attacks
          perform_attack_sequence(num_attacks, combatant, target, attack, combat)
          try_extra_attacks(combatant, target, attack, combat)
        end

        def perform_attack_sequence(num, combatant, target, attack, combat)
          num.times do
            # Re-acquire target if current one is dead or missing
            target = ensure_alive_target(combatant, target, combat)
            break unless target

            execute_sequence_attack(combatant, target, attack, combat)
            try_cleave_attack(combatant, target, attack, combat)
          end
        end

        def execute_sequence_attack(combatant, target, attack, combat)
          combat.attack(combatant, target, attack: attack)
          combatant.statblock.resources.consume(attack.resource_cost) if attack.resource_cost
        end

        def select_attack(combatant, target, combat)
          nick = combatant.attacks.find { |a| a.mastery == :nick }
          return nick if nick && combatant.statblock.resources.available?(nick.resource_cost)

          combatant.attacks.find do |attack|
            combatant.statblock.resources.available?(attack.resource_cost) &&
              !self_damage?(combatant, target, attack, combat)
          end
        end

        def self_damage?(combatant, target, attack, combat)
          return false unless attack.area_radius

          dist = combat.grid.distance(combatant, target)
          dist < attack.area_radius
        end

        def try_second_wind(combatant, combat)
          return unless second_wind_available?(combatant)

          combatant.statblock.resources.consume(:second_wind)
          combat.notify_observers(:resource_used, { combatant: combatant, resource: :second_wind })
          heal_combatant(combatant)
        end

        def second_wind_available?(combatant)
          combatant.statblock.resources.available?(:second_wind) &&
            combatant.statblock.hit_points < combatant.statblock.calculate_hit_points / 2
        end

        def heal_combatant(combatant)
          combatant.statblock.heal(DiceRoller.new.roll("1d10+#{combatant.statblock.level}"))
        end

        def try_action_surge(combatant, combat)
          return unless combatant.statblock.resources.available?(:action_surge)

          combatant.statblock.resources.consume(:action_surge)
          combat.notify_observers(:resource_used, { combatant: combatant, resource: :action_surge })

          # 2024: Action Surge grants one additional action.
          # We manually reset availability just for this call.
          original_actions = combatant.turn_context.instance_variable_get(:@actions_used)
          combatant.turn_context.instance_variable_set(:@actions_used, 0)
          execute_action(combatant, combat)
          # Restoration: If execute_action used the surge action, actions_used should now be 1.
          # We want to restore the PRE-surge state PLUS the fact that we might have used the surge.
          # However, simple restoration to (original + 1) is safer if surge is always 1 action.
          combatant.turn_context.instance_variable_set(:@actions_used, original_actions + 1)
        end

        def find_target(combatant, combat)
          combat.find_valid_defender(combatant)
        end
      end
    end
  end
end
