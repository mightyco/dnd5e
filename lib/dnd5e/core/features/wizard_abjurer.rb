# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Arcane Ward (Abjurer) feature.
      class ArcaneWard < Feature
        attr_accessor :ward_hp, :max_ward_hp

        def initialize(level: 1, intelligence: 10)
          super(name: 'Arcane Ward')
          int_mod = (intelligence - 10) / 2
          @max_ward_hp = (2 * level) + int_mod
          @ward_hp = @max_ward_hp
        end

        def on_damage_taken(context)
          damage = context[:current_value]
          return damage if @ward_hp.zero?

          absorbed = [damage, @ward_hp].min
          @ward_hp -= absorbed
          damage - absorbed
        end

        def on_turn_start(context)
          # In 2024, Arcane Ward can be recharged.
          # For simplicity, we won't implement recharge here.
        end
      end
    end
  end
end
