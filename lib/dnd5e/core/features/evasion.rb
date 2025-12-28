# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Evasion class feature.
      class Evasion < Feature
        def initialize
          super(name: 'Evasion')
        end

        def on_damage_taken(context)
          return nil unless eligible?(context)

          if context[:save_success]
            0
          else
            (context[:damage] / 2).floor
          end
        end

        private

        def eligible?(context)
          # Only applies to Dex saves for half damage
          context[:attack].type == :save &&
            context[:attack].save_ability == :dexterity &&
            context[:attack].half_damage_on_save
        end
      end
    end
  end
end
