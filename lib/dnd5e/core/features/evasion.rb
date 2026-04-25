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
          damage = context[:current_value]
          return damage unless context[:attack]&.save_ability == :dexterity

          if context[:save_success]
            0
          else
            (damage / 2).floor
          end
        end
      end
    end
  end
end
