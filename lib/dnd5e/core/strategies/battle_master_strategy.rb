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
          attempt_second_wind(combatant, combat)
          target, attack = prepare_turn_data(combatant, combat)

          if target && attack
            # Use Tactical Shift (bonus move) if we used Second Wind and are not in range
            try_tactical_shift_move(combatant, target, combat) if combatant.turn_context.bonus_actions_used.positive?
            move_towards_target(combatant, target, attack, combat)
          end

          # execute_action is called here, which calls perform_action_cycle -> execute_battle_master_attacks
          execute_action(combatant, combat)
          post_action_movement(combatant, combat)
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

        def post_action_movement(combatant, combat)
          target, attack = prepare_turn_data(combatant, combat)
          return unless target && attack

          # 2024 Tactical AI: Kite away if the target is prone or frightened
          if should_kite?(combatant, target, combat)
            move_away_from_target(combatant, target, combat)
          else
            move_towards_target(combatant, target, attack, combat)
          end
        end

        def execute_battle_master_attacks(combatant, target, attack, combat)
          num_attacks = attack.type == :save ? 1 : 1 + combatant.statblock.extra_attacks
          # We must manually implement the loop here to pass options to each attack
          num_attacks.times do
            # Re-acquire target
            current_target = determine_best_target(combatant, target, attack, combat)
            break unless current_target

            execute_sequence_attack(combatant, current_target, attack, combat)
            try_cleave_attack(combatant, current_target, attack, combat)
          end
          try_extra_attacks(combatant, target, attack, combat)
        end

        def execute_sequence_attack(combatant, target, attack, combat)
          options = { attack: attack, combat: combat }
          if @use_damage_maneuver && combatant.statblock.resources.available?(:superiority_dice)
            options[:maneuver] = pick_maneuver(combatant, target)
          end

          # Use the combat instance to perform the attack with maneuver options
          combat.attack(combatant, target, **options)
          combatant.statblock.resources.consume(attack.resource_cost) if attack.resource_cost
        end

        def pick_maneuver(combatant, target)
          return @maneuver_choice if @maneuver_choice

          # 1. Trip if not already prone (grant advantage on melee)
          return :trip_attack if !target.prone? && combatant.attacks.any? { |a| a.range <= 5 }

          # 2. Menacing if not already frightened (best control)
          return :menacing_attack unless target.condition?(:frightened)

          # 3. Pushing if we need to disengage
          return :pushing_attack if combatant.statblock.hit_points < combatant.statblock.max_hp / 2

          # Default to Trip or Menacing
          :trip_attack
        end

        def perform_action_cycle(combatant, target, attack, combat)
          if in_range?(combatant, target, attack, combat)
            execute_battle_master_attacks(combatant, target, attack, combat)
          else
            move_towards_target(combatant, target, attack, combat)
            execute_battle_master_attacks(combatant, target, attack, combat) if in_range?(combatant, target, attack,
                                                                                          combat)
          end
        end

        def try_tactical_shift_move(combatant, target, combat)
          return if in_range?(combatant, target, nil, combat)

          bm_feat = combatant.feature_manager.features.find { |f| f.name == 'Battle Master' }
          move_dist = bm_feat&.apply_tactical_shift(combatant, combat)
          return unless move_dist

          execute_tactical_move(combatant, target, move_dist, combat)
        end

        def execute_tactical_move(combatant, target, move_dist, combat)
          current_pos = combat.grid.find_position(combatant)
          target_pos = combat.grid.find_position(target)
          return unless current_pos && target_pos

          path = Helpers::Pathfinder.new(combat.grid).find_path(current_pos, target_pos)
          return if path.empty?

          segment, = calculate_move_segment(path, move_dist, combat.grid)
          combat.move_combatant(combatant, segment)
        end
      end
    end
  end
end
