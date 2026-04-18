# frozen_string_literal: true

module Dnd5e
  module Core
    module Strategies
      # Extra attack logic for SimpleStrategy.
      module ExtraAttackHelper
        private

        def try_extra_attacks(combatant, target, attack, combat)
          return unless target.statblock.alive?

          try_nick_attack(combatant, target, combat)
          return unless target.statblock.alive?

          try_dual_wielder_attack(combatant, target, combat)
          return unless target.statblock.alive?

          try_gwm_bonus_attack(combatant, target, attack, combat)
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
          return if in_range?(attack, combat) && !should_kite?(combatant, combat)

          speed = combatant.statblock.speed
          target_pos = combat.grid.find_position(target)
          current_pos = combat.grid.find_position(combatant)
          return unless target_pos && current_pos

          execute_grid_move(combatant, current_pos, target_pos, speed, combat)
          combatant.turn_context.use_movement(speed)
        end

        def execute_grid_move(combatant, current_pos, target_pos, speed, combat)
          new_x = calc_new_x(current_pos.x, target_pos.x, speed, should_kite?(combatant, combat))
          combat.move_combatant(combatant, Point2D.new(new_x, 0))
        end

        def calc_new_x(cur_x, target_x, speed, kiting)
          if speed.zero? then cur_x
          elsif kiting then target_x > cur_x ? cur_x - speed : cur_x + speed
          else
            dist_x = (target_x - cur_x).abs
            move_dist = [speed, dist_x].min
            target_x > cur_x ? cur_x + move_dist : cur_x - move_dist
          end
        end

        def should_kite?(combatant, combat)
          combat.distance <= 5 && combatant.attacks.any? { |a| a.range > 5 }
        end

        def in_range?(attack, combat)
          combat.distance <= attack.range
        end

        def execute_attacks(combatant, target, attack, combat)
          num_attacks = attack.type == :save ? 1 : 1 + combatant.statblock.extra_attacks
          perform_attack_sequence(num_attacks, combatant, target, attack, combat)
          try_extra_attacks(combatant, target, attack, combat)
        end

        def perform_attack_sequence(num, combatant, target, attack, combat)
          num.times do
            break unless target.statblock.alive?

            combat.attack(combatant, target, attack: attack)
            break unless target.statblock.alive?

            combatant.statblock.resources.consume(attack.resource_cost) if attack.resource_cost
            try_cleave_attack(combatant, target, attack, combat)
          end
        end

        def select_attack(combatant, combat)
          nick = combatant.attacks.find { |a| a.mastery == :nick }
          return nick if nick && combatant.statblock.resources.available?(nick.resource_cost)

          combatant.attacks.find do |attack|
            combatant.statblock.resources.available?(attack.resource_cost) &&
              !self_damage?(combatant, attack, combat)
          end
        end

        def self_damage?(_combatant, attack, combat)
          attack.area_radius && combat.distance < attack.area_radius
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
          combatant.turn_context.reset!
          execute_action(combatant, combat)
        end

        def find_target(combatant, combat)
          combat.find_valid_defender(combatant)
        end
      end
    end
  end
end
