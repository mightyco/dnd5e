# frozen_string_literal: true

require_relative 'attack_result'

module Dnd5e
  module Core
    # Builds AttackResult objects.
    class AttackResultBuilder
      def build(attacker:, defender:, attack:, outcome:, details:)
        AttackResult.new(
          combat_context: { attacker: attacker, defender: defender, attack: attack },
          outcome: outcome,
          type: details[:type] || :attack,
          **details
        )
      end
    end
  end
end
