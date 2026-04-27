# frozen_string_literal: true

require 'json'
require_relative 'combat_result_handler'
require_relative 'attack_formatting'

module Dnd5e
  module Simulation
    # Collects detailed combat data and exports it as JSON for visualization.
    class JSONCombatResultHandler < CombatResultHandler
      include AttackFormatting

      attr_reader :combat_data

      def initialize
        super
        @combat_data = []
        @current_combat = nil
        @combatants_list = []
      end

      def update(event, data)
        case event
        when :combat_start then handle_combat_start(data)
        when :round_start then handle_round_start(data)
        when :turn_start then handle_turn_start(data)
        when :move_resolved then handle_move_resolved(data)
        when :resource_used then handle_resource_used(data)
        else handle_result_events(event, data)
        end
      end

      def to_json(*_args)
        JSON.pretty_generate(@combat_data)
      end

      private

      def handle_result_events(event, data)
        case event
        when :attack_resolved then handle_attack_resolved(data)
        when :combat_end then handle_combat_end(data)
        end
      end

      def handle_combat_start(data)
        @combatants_list = data[:combatants]
        @current_combat = {
          teams: @combatants_list.map(&:name),
          rounds: [],
          initial_positions: spatial_snapshot(data[:combat])
        }
      end

      def handle_round_start(data)
        @current_combat[:rounds] << { number: data[:round], events: [] }
      end

      def handle_turn_start(data)
        @current_combat[:rounds].last[:events] << {
          type: 'turn_start',
          combatant: data[:combatant].name,
          snapshot: spatial_snapshot(data[:combat])
        }
      end

      def handle_move_resolved(data)
        @current_combat[:rounds].last[:events] << {
          type: 'move',
          combatant: data[:combatant].name,
          to: { x: data[:position].x, y: data[:position].y, z: data[:combatant].statblock.altitude }
        }
      end

      def handle_resource_used(data)
        @current_combat[:rounds].last[:events] << { type: 'resource_used', combatant: data[:combatant].name,
                                                    resource: data[:resource] }
      end

      def handle_attack_resolved(data)
        return unless @current_combat

        result = data[:result]
        event = format_attack_event(result)
        event[:snapshot] = spatial_snapshot(nil)
        @current_combat[:rounds].last[:events] << event
      end

      def handle_combat_end(data)
        return unless @current_combat

        @current_combat[:winner] = identify_winner(data[:winner])
        @current_combat[:combatants] = format_combatants(data[:combatants])
        @current_combat[:initiative_winner] = data[:initiative_winner]&.name
        @combat_data << @current_combat
        @current_combat = nil
      end

      def identify_winner(winner)
        winner.respond_to?(:name) ? winner.name : winner.to_s
      end

      def format_combatants(combatants)
        combatants.map do |c|
          { name: c.name, hit_points: c.statblock.hit_points, max_hp: c.statblock.max_hp }
        end
      end

      def spatial_snapshot(combat)
        @combatants_list.each_with_object({}) do |combatant, hash|
          hash[combatant.name] = combatant_data(combatant, combat)
        end
      end

      def combatant_data(combatant, combat)
        pos = combat ? combat.grid.find_position(combatant) : find_ctx_pos(combatant)
        { x: pos&.x || 0, y: pos&.y || 0, z: combatant.statblock.altitude,
          hp: combatant.statblock.hit_points, max_hp: combatant.statblock.max_hp }
      end

      def find_ctx_pos(combatant)
        combatant.instance_variable_get(:@combat_context)&.grid&.find_position(combatant)
      end
    end
  end
end
