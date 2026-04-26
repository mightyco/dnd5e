# frozen_string_literal: true

require_relative 'simple_strategy'

module Dnd5e
  module Core
    module Strategies
      # Strategy for Battle Master fighters.
      class BattleMasterStrategy < SimpleStrategy
        attr_accessor :use_precision_attack, :use_damage_maneuver, :precision_threshold

        def initialize(use_precision_attack: false, use_damage_maneuver: true, precision_threshold: 4)
          super()
          @name = 'BattleMaster'
          @use_precision_attack = use_precision_attack
          @use_damage_maneuver = use_damage_maneuver
          @precision_threshold = precision_threshold
        end

        def execute_turn(combatant, combat)
          try_second_wind(combatant, combat)

          target, attack = prepare_turn_data(combatant, combat)
          if target && attack
            try_tactical_shift(combatant, target, attack, combat)
            move_towards_target(combatant, target, attack, combat)
          end

          execute_action(combatant, combat)

          target, attack = prepare_turn_data(combatant, combat)
          move_towards_target(combatant, target, attack, combat) if target && attack

          try_action_surge(combatant, combat)
        end

        def should_use_precision_attack?(context)
          return false unless @use_precision_attack

          roll_data = context[:current_value]
          ac = context[:defender].statblock.armor_class

          miss_by = ac - roll_data[:total]
          miss_by.positive? && miss_by <= @precision_threshold
        end

        private

        def perform_action_cycle(combatant, target, attack, combat)
          if in_range?(combatant, target, attack, combat)
            execute_battle_master_attacks(combatant, target, attack, combat)
          else
            combatant.turn_context.instance_variable_set(:@movement_used, 0)
            move_towards_target(combatant, target, attack, combat)
          end
        end

        def execute_battle_master_attacks(combatant, target, attack, combat)
          num_attacks = attack.type == :save ? 1 : 1 + combatant.statblock.extra_attacks
          perform_attack_sequence(num_attacks, combatant, target, attack, combat)
          try_multi_attacks(combatant, target, attack, combat)
        end

        def execute_sequence_attack(combatant, target, attack, combat)
          options = { attack: attack, combat: combat }
          if @use_damage_maneuver && combatant.statblock.resources.available?(:superiority_dice)
            options[:maneuver] = pick_maneuver(combatant, target)
          end

          combat.attack(combatant, target, **options)
          combatant.statblock.resources.consume(attack.resource_cost) if attack.resource_cost
        end

        def execute_dash_if_needed(combatant, target, attack, combat)
          combatant.turn_context.instance_variable_set(:@movement_used, 0)
          move_towards_target(combatant, target, attack, combat)
        end

        def try_tactical_shift(combatant, target, attack, combat)
          return if in_range?(combatant, target, attack, combat)
          return unless combatant.turn_context.bonus_action_available?

          bm_feat = combatant.feature_manager.features.find { |f| f.name == 'Battle Master' }
          move_dist = bm_feat&.apply_tactical_shift(combatant, combat)
          return unless move_dist

          execute_tactical_move(combatant, target, move_dist, combat)
          combatant.turn_context.use_bonus_action
        end

        def execute_tactical_move(combatant, target, move_dist, combat)
          current_pos = combat.grid.find_position(combatant)
          target_pos = combat.grid.find_position(target)
          return unless current_pos && target_pos

          path = Helpers::Pathfinder.new(combat.grid).find_path(current_pos, target_pos)
          return if path.empty?

          max_squares = move_dist / 5
          combat.move_combatant(combatant, path[0...max_squares])
        end

        def pick_maneuver(combatant, target)
          if !target.prone? && combatant.attacks.any? { |a| a.range <= 5 }
            :trip_attack
          else
            :menacing_attack
          end
        end

        def try_multi_attacks(combatant, target, attack, combat)
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
      end
    end
  end
end
