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
          @use_precision_attack = use_precision_attack
          @use_damage_maneuver = use_damage_maneuver
          @precision_threshold = precision_threshold
        end

        def execute_action(combatant, combat)
          return unless combatant.turn_context.action_available?

          target = find_target(combatant, combat)
          attack = select_attack(combatant, combat)
          return unless target && attack

          try_tactical_shift(combatant, target, attack, combat)
          move_towards_target(combatant, target, attack, combat)
          return unless in_range?(attack, combat)

          execute_battle_master_attacks(combatant, target, attack, combat)
          combatant.turn_context.use_action
        end

        def should_use_precision_attack?(context)
          return false unless @use_precision_attack

          roll_data = context[:current_value]
          ac = context[:defender].statblock.armor_class

          miss_by = ac - roll_data[:total]
          miss_by.positive? && miss_by <= @precision_threshold
        end

        private

        def try_tactical_shift(combatant, _target, attack, combat)
          return if in_range?(attack, combat)
          return unless combatant.turn_context.bonus_action_available?

          bm_feature = combatant.feature_manager.features.find { |f| f.name == 'Battle Master' }
          return unless bm_feature

          move_dist = bm_feature.apply_tactical_shift(combatant, combat)
          return unless move_dist

          # Move towards target (1D)
          new_dist = [0, combat.distance - move_dist].max
          combat.move_combatant(combatant, new_dist)
          combatant.turn_context.use_bonus_action
        end

        def execute_battle_master_attacks(combatant, target, attack, combat)
          num_attacks = attack.type == :save ? 1 : 1 + combatant.statblock.extra_attacks
          num_attacks.times do
            break unless target.statblock.alive?

            execute_single_battle_master_attack(combatant, target, attack, combat)
            try_cleave_attack(combatant, target, attack, combat)
          end

          try_multi_attacks(combatant, target, attack, combat)
        end

        def execute_single_battle_master_attack(combatant, target, attack, combat)
          options = { attack: attack, combat: combat }
          if @use_damage_maneuver && combatant.statblock.resources.available?(:superiority_dice)
            options[:maneuver] = pick_maneuver(combatant, target)
          end

          combat.attack(combatant, target, **options)
        end

        def pick_maneuver(combatant, target)
          if !target.prone? && combatant.attacks.any? { |a| a.range <= 5 }
            :trip_attack
          else
            :menacing_attack
          end
        end

        def try_multi_attacks(combatant, target, attack, combat)
          try_nick_attack(combatant, target, attack, combat)
          try_dual_wielder_attack(combatant, target, attack, combat)
          try_gwm_bonus_attack(combatant, target, attack, combat)
        end
      end
    end
  end
end
