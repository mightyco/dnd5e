# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/features/fighting_styles'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/armor'

module Dnd5e
  module Core
    module Features
      class TestFightingStyles < Minitest::Test
        def setup
          @stat = Statblock.new(name: 'Hero', strength: 16, dexterity: 16)
        end

        def test_archery_style
          archery = ArcheryStyle.new
          hero = Character.new(name: 'Archer', statblock: @stat, features: [archery])

          longbow = Attack.new(name: 'Longbow', damage_dice: '1d8', relevant_stat: :dexterity, properties: [:ranged])
          context = { attacker: hero, attack: longbow, options: {} }

          bonus = hero.feature_manager.apply_modifier_hook(:on_attack_roll, context, 0)

          assert_equal 2, bonus
        end

        def test_dueling_style
          dueling = DuelingStyle.new
          hero = Character.new(name: 'Duelist', statblock: @stat, features: [dueling])

          longsword = Attack.new(name: 'Longsword', damage_dice: '1d8', relevant_stat: :strength, properties: [:melee])
          # context for extra_damage_modifier
          context = { attacker: hero, attack: longsword, options: {} }

          extra = hero.feature_manager.apply_modifier_hook(:extra_damage_modifier, context, 0)

          assert_equal 2, extra
        end

        def test_defense_style
          defense = DefenseStyle.new
          hero = Character.new(name: 'Defender', statblock: @stat, features: [defense])

          # Defense gives +1 AC if wearing armor
          armor = Armor.new(name: 'Breastplate', base_ac: 14, type: :medium)
          hero.statblock.instance_variable_set(:@equipped_armor, armor)

          ac = hero.statblock.armor_class # This should trigger the ac_bonus hook
          # Base AC 14 + Dex 3 + Defense 1 = 18
          assert_equal 18, ac
        end
      end
    end
  end
end
