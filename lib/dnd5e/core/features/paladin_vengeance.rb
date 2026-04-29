# frozen_string_literal: true

require_relative '../feature'
module Dnd5e
  module Core
    module Features
      # Feature for Paladin Vow of Enmity.
      class VowOfEnmity < Feature
        def initialize = super(name: 'Vow of Enmity')

        def on_after_attack_roll(context, roll_data)
          roll_data[:advantage] = true if context[:options][:vow_target]
          roll_data
        end
      end
    end
  end
end
