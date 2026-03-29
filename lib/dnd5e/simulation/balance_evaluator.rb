# frozen_string_literal: true

require 'json'

module Dnd5e
  module Simulation
    # Evaluates simulation results against defined expectations.
    class BalanceEvaluator
      def evaluate(results, expectations)
        return { status: :pass, details: [] } if expectations.nil? || expectations.empty?

        outcomes = expectations.map { |exp| evaluate_expectation(results, exp) }
        status = outcomes.all? { |o| o[:status] == :pass } ? :pass : :fail
        { status: status, details: outcomes }
      end

      private

      def evaluate_expectation(results, exp)
        actual = calculate_metric(results, exp['metric'], exp['combatant'])
        margin = exp['margin'] || 0

        passed = actual.between?(exp['min'] - margin, exp['max'] + margin)
        { status: passed ? :pass : :fail, metric: exp['metric'], actual: actual,
          min: exp['min'], max: exp['max'] }
      end

      def calculate_metric(results, metric, combatant_name)
        case metric
        when 'dpr' then calculate_avg_dpr(results, combatant_name)
        when 'win_rate' then calculate_win_rate(results, combatant_name)
        else 0
        end
      end

      def calculate_avg_dpr(results, name)
        total_dmg = 0
        total_rounds = 0
        results.each do |c|
          total_rounds += c['rounds'].length
          c['rounds'].each { |r| total_dmg += r['events'].select { |e| e['attacker'] == name }.sum { |e| e['damage'] } }
        end
        total_dmg.to_f / total_rounds
      end

      def calculate_win_rate(results, name)
        wins = results.count { |c| c['winner'] == name || c['winner'].include?(name) }
        (wins.to_f / results.length) * 100
      end
    end
  end
end
