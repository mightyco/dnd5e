# frozen_string_literal: true

require_relative '../core/team_combat'
require_relative '../core/team'
require_relative '../builders/monster_builder'
require_relative 'silent_combat_result_handler'

module Dnd5e
  module Simulation
    # Runs a combatant through a standardized suite of encounters to measure efficiency.
    class StandardEncounterSuite
      attr_reader :results

      def initialize(combatant_builder, num_simulations: 100)
        @builder = combatant_builder
        @num_simulations = num_simulations
        @results = {}
      end

      def run_all
        @results[:boss] = run_scenario('The Boss', 1, hp: 100, ac: 18, dmg: '2d8+5')
        @results[:pack] = run_scenario('The Pack', 5, hp: 30, ac: 14, dmg: '1d8+3')
        @results[:swarm] = run_scenario('The Swarm', 15, hp: 7, ac: 10, dmg: '1d4+1')
        calculate_aggregate_score
        self
      end

      private

      def run_scenario(name, count, m_stats)
        data = { name: name, deals: 0, takes: 0, wins: 0 }
        @num_simulations.times { record_iteration(data, count, m_stats) }
        finalize_scenario_data(data)
      end

      def record_iteration(data, count, m_stats)
        hero = @builder.call
        combat = Core::TeamCombat.new(teams: [
                                        Core::Team.new(name: 'Hero', members: [hero]),
                                        build_monster_team(count, m_stats)
                                      ], max_rounds: 100)
        combat.run_combat
        data[:deals] += hero.statblock.damage_dealt
        data[:takes] += hero.statblock.damage_taken
        data[:wins] += 1 if hero.statblock.alive?
      end

      def build_monster_team(count, m_stats)
        monsters = (1..count).map { |i| build_monster("M#{i}", m_stats) }
        Core::Team.new(name: 'Monsters', members: monsters)
      end

      def finalize_scenario_data(data)
        data[:avg_deal] = data[:deals].to_f / @num_simulations
        data[:avg_take] = data[:takes].to_f / @num_simulations
        data[:win_rate] = (data[:wins].to_f / @num_simulations * 100).round(1)
        data[:efficiency] = calculate_efficiency(data)
        data
      end

      def calculate_efficiency(data)
        return data[:deals].to_f unless data[:takes].positive?

        (data[:deals].to_f / data[:takes]).round(2)
      end

      def calculate_aggregate_score
        total_efficiency = @results.values.sum { |r| r[:efficiency] }
        @results[:aggregate_efficiency] = (total_efficiency / 3.0).round(2)
      end

      def build_monster(name, stats)
        Dnd5e::Builders::MonsterBuilder.new(name: name)
                                       .with_statblock(Core::Statblock.new(name: name, hit_points: stats[:hp],
                                                                           armor_class: stats[:ac]))
                                       .with_attack(Core::Attack.new(name: 'Attack',
                                                                     damage_dice: Core::Dice.parse(stats[:dmg])))
                                       .build
      end
    end
  end
end
