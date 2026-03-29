# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/subclass_registry'

module Dnd5e
  module Core
    class TestSubclassRegistry < Minitest::Test
      def test_battlemaster_features_returns_battle_master_feature
        features = SubclassRegistry.features_for(:battlemaster, 3)

        assert_equal 1, features.length
        assert_instance_of Features::BattleMaster, features.first
        assert_equal 3, features.first.level
      end

      def test_battlemaster_features_respects_level
        features = SubclassRegistry.features_for(:battlemaster, 10)

        assert_equal 10, features.first.level
      end

      def test_battlemaster_strategy_returns_battle_master_strategy
        strategy = SubclassRegistry.strategy_for(:battlemaster, 3)

        assert_instance_of Strategies::BattleMasterStrategy, strategy
        assert_equal 'BattleMaster', strategy.name
      end

      def test_champion_features_returns_improved_critical
        features = SubclassRegistry.features_for(:champion, 5)

        assert_equal 1, features.length
        assert_instance_of Features::ImprovedCritical, features.first
      end

      def test_champion_strategy_returns_simple_strategy
        strategy = SubclassRegistry.strategy_for(:champion, 5)

        assert_instance_of Strategies::SimpleStrategy, strategy
        assert_equal 'Simple', strategy.name
      end

      def test_accepts_string_subclass_key
        features = SubclassRegistry.features_for('battlemaster', 3)

        assert_instance_of Features::BattleMaster, features.first
      end

      def test_unknown_subclass_raises_argument_error
        assert_raises(ArgumentError) { SubclassRegistry.features_for(:paladin, 3) }
        assert_raises(ArgumentError) { SubclassRegistry.strategy_for(:paladin, 3) }
      end

      def test_known_returns_true_for_valid_subclasses
        assert SubclassRegistry.known?(:battlemaster)
        assert SubclassRegistry.known?(:champion)
        assert SubclassRegistry.known?('battlemaster')
      end

      def test_known_returns_false_for_unknown_subclass
        refute SubclassRegistry.known?(:paladin)
        refute SubclassRegistry.known?(:rogue)
      end
    end
  end
end
