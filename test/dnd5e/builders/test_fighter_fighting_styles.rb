# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Builders
    class TestFighterFightingStyles < Minitest::Test
      def test_fighter_archery_style
        hero = CharacterBuilder.new(name: 'Archer')
                               .as_fighter(level: 1)
                               .with_fighting_style(:archery)
                               .build

        assert(hero.feature_manager.features.any? { |f| f.is_a?(Core::Features::ArcheryStyle) })
      end

      def test_fighter_dueling_style
        hero = CharacterBuilder.new(name: 'Duelist')
                               .as_fighter(level: 1)
                               .with_fighting_style(:dueling)
                               .build

        assert(hero.feature_manager.features.any? { |f| f.is_a?(Core::Features::DuelingStyle) })
      end
    end
  end
end
