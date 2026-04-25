# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Builders
    class TestWizardBuilder < Minitest::Test
      def setup
        @builder = CharacterBuilder.new(name: 'Gale')
      end

      def test_build_evoker
        wizard = @builder.as_wizard(level: 10, subclass: :evoker).build

        assert(wizard.feature_manager.features.any? { |f| f.name == 'Sculpt Spells' })
        assert(wizard.feature_manager.features.any? { |f| f.name == 'Empowered Evocation' })
      end

      def test_build_abjurer
        wizard = @builder.as_wizard(level: 10, subclass: :abjurer).build

        assert(wizard.feature_manager.features.any? { |f| f.name == 'Arcane Ward' })
      end
    end
  end
end
