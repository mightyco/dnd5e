# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/dice'
require_relative '../../../lib/dnd5e/core/strategies/battle_master_strategy'
require_relative '../../../lib/dnd5e/core/strategies/simple_strategy'

module Dnd5e
  module Builders
    class TestCharacterBuilderFoundation < Minitest::Test
      def test_builder
        builder = CharacterBuilder.new(name: 'Aragorn')
        builder.with_statblock(Core::Statblock.new(name: 'Aragorn', strength: 18))
        builder.with_attack(Core::Attack.new(name: 'Sword', damage_dice: Core::Dice.new(1, 8)))
        character = builder.build

        assert_basic_character(character, 'Aragorn', 18)
        assert_equal 1, character.attacks.length
        assert_equal 'Sword', character.attacks.first.name
      end

      def test_with_subclass_battlemaster_sets_features_and_strategy
        character = CharacterBuilder.new(name: 'BM')
                                    .as_fighter(level: 3)
                                    .with_subclass(:battlemaster)
                                    .build

        assert_instance_of Core::Strategies::BattleMasterStrategy, character.strategy
        assert(character.feature_manager.features.any? { |f| f.name == 'Battle Master' })
      end

      def test_with_subclass_champion_sets_feature
        character = CharacterBuilder.new(name: 'Champ')
                                    .as_fighter(level: 5)
                                    .with_subclass(:champion)
                                    .build

        assert(character.feature_manager.features.any? { |f| f.is_a?(Core::Features::ImprovedCritical) })
      end

      def test_with_strategy_override_takes_precedence_over_subclass
        custom = Core::Strategies::SimpleStrategy.new
        character = CharacterBuilder.new(name: 'BM Custom')
                                    .as_fighter(level: 3)
                                    .with_subclass(:battlemaster)
                                    .with_strategy(custom)
                                    .build

        assert_same custom, character.strategy
      end

      def test_build_without_subclass_uses_simple_strategy
        character = CharacterBuilder.new(name: 'Plain')
                                    .as_fighter(level: 1)
                                    .build

        assert_instance_of Core::Strategies::SimpleStrategy, character.strategy
      end

      def test_magic_armor_and_weapon
        character = CharacterBuilder.new(name: 'Magic Man')
                                    .as_fighter(level: 1)
                                    .with_magic_weapon('Longsword', 2)
                                    .with_magic_armor(1)
                                    .build

        assert_equal 2, character.attacks.first.instance_variable_get(:@magic_bonus)
        assert_equal 1, character.statblock.equipped_armor.instance_variable_get(:@magic_bonus)
        assert_equal 17, character.statblock.armor_class # 16 (Chain Mail) + 1 (Magic)
      end

      private

      def assert_basic_character(character, name, strength)
        assert_equal name, character.name
        assert_equal strength, character.statblock.strength
      end
    end

    class TestCharacterBuilderAdditions < Minitest::Test
      def test_with_spell
        spell = { name: 'Fireball' }
        character = CharacterBuilder.new(name: 'Mage')
                                    .as_wizard(level: 5)
                                    .with_spell(spell)
                                    .build

        assert_includes character.spells, spell
      end

      def test_with_magic_armor_nil_safety
        character = CharacterBuilder.new(name: 'Plain')
                                    .as_barbarian(level: 1)
                                    .with_magic_armor(1)
                                    .build

        assert_nil character.statblock.equipped_armor
      end

      def test_merge_abilities
        builder = CharacterBuilder.new(name: 'Test')
        merged = builder.send(:merge_abilities, { strength: 18, charisma: 14 })

        assert_equal 18, merged[:strength]
        assert_equal 14, merged[:charisma]
        assert_equal 10, merged[:dexterity]
      end

      def test_with_magic_weapon_mismatch
        character = CharacterBuilder.new(name: 'Plain')
                                    .as_fighter(level: 1)
                                    .with_magic_weapon('Missing', 5)
                                    .build

        assert_equal 0, character.attacks.first.instance_variable_get(:@magic_bonus)
      end

      def test_with_magic_weapon_case_insensitivity
        character = CharacterBuilder.new(name: 'Fighter')
                                    .as_fighter(level: 1)
                                    .with_magic_weapon('longsword', 3)
                                    .build

        assert_equal 3, character.attacks.first.instance_variable_get(:@magic_bonus)
      end

      def test_with_strategy
        strategy = Core::Strategies::SimpleStrategy.new
        character = CharacterBuilder.new(name: 'Tactician')
                                    .as_fighter(level: 1)
                                    .with_strategy(strategy)
                                    .build

        assert_equal strategy, character.strategy
      end

      def test_with_feat
        character = CharacterBuilder.new(name: 'Tough Guy')
                                    .as_fighter(level: 1)
                                    .with_feat(:tough)
                                    .build

        assert(character.feature_manager.features.any? { |f| f.is_a?(Core::Features::Tough) })
      end

      def test_build_invalid_name
        builder = CharacterBuilder.new(name: '')
        assert_raises(CharacterBuilder::InvalidCharacterError) { builder.build }

        builder = CharacterBuilder.new(name: nil)
        assert_raises(CharacterBuilder::InvalidCharacterError) { builder.build }
      end
    end
  end
end
