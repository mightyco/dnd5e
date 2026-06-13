# frozen_string_literal: true

require_relative 'attack_result'

module Dnd5e
  module Core
    # Builds AttackResult objects.
    class AttackResultBuilder
      def initialize(logger: nil)
        @logger = logger
      end

      def build(attacker:, defender:, attack:, outcome:, details:)
        res = AttackResult.new(
          combat_context: { attacker: attacker, defender: defender, attack: attack },
          outcome: outcome,
          type: details[:type] || :attack,
          **details
        )
        log_result(res) if @logger
        res
      end

      private

      def log_result(res)
        # Standardized logging if needed, or just delegating to existing logic
      end
    end
  end
end
