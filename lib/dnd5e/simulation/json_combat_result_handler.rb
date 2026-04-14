# frozen_string_literal: true

require 'json'
require_relative 'combat_result_handler'

module Dnd5e
  module Simulation
    # Collects detailed combat data and exports it as JSON for visualization.
    class JSONCombatResultHandler < CombatResultHandler
      attr_reader :combat_data

      def initialize
        super
        @combat_data = []
        @current_combat = nil
      end

      def update(event, data)
        case event
        when :combat_start then handle_combat_start(data)
        when :round_start then handle_round_start(data)
        when :turn_start then handle_turn_start(data)
        when :resource_used then handle_resource_used(data)
        when :attack_resolved then handle_attack_resolved(data)
        when :combat_end then handle_combat_end(data)
        end
      end

      def to_json(*_args)
        JSON.pretty_generate(@combat_data)
      end

      private

      def handle_combat_start(data)
        @current_combat = { teams: data[:combatants].map(&:name), rounds: [] }
      end

      def handle_round_start(data)
        @current_combat[:rounds] << { number: data[:round], events: [] }
      end

      def handle_turn_start(data)
        @current_combat[:rounds].last[:events] << { type: 'turn_start', combatant: data[:combatant].name }
      end

      def handle_resource_used(data)
        @current_combat[:rounds].last[:events] << { type: 'resource_used', combatant: data[:combatant].name,
                                                    resource: data[:resource] }
      end

      def handle_attack_resolved(data)
        return unless @current_combat

        result = data[:result]
        event = format_attack_event(result)
        @current_combat[:rounds].last[:events] << event
      end

      def handle_combat_end(data)
        return unless @current_combat

        @current_combat[:winner] = data[:winner]&.name
        @current_combat[:combatants] = data[:combatants].map do |c|
          { name: c.name, hit_points: c.statblock.hit_points, max_hp: c.statblock.max_hp }
        end
        @current_combat[:initiative_winner] = data[:initiative_winner]&.name
        @combat_data << @current_combat
        @current_combat = nil
      end

      def format_attack_event(result)
        base = { type: result.type, attacker: result.attacker.name, defender: result.defender.name,
                 attack_name: result.attack.name, success: result.success }
        base.merge(damage: result.damage, is_crit: result.is_crit, is_dead: result.is_dead,
                   metadata: extract_metadata(result))
      end

      def extract_metadata(result)
        extract_roll_metadata(result).merge(extract_save_metadata(result))
      end

      def extract_roll_metadata(result)
        { attack_roll: result.attack_roll, picked_roll: result.raw_roll, raw_rolls: result.rolls,
          modifier: result.modifier, proficiency_bonus: result.proficiency_bonus,
          target_ac: result.target_ac }.merge(extract_damage_metadata(result))
      end

      def extract_damage_metadata(result)
        { damage_rolls: result.damage_rolls, damage_modifier: result.damage_modifier,
          current_hp: result.current_hp, max_hp: result.max_hp }
      end

      def extract_save_metadata(result)
        {
          save_roll: result.save_roll,
          save_dc: result.save_dc
        }
      end
    end
  end
end
