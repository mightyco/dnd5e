# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/dnd5e/core/subclass_registry'

module Dnd5e
  module Core
    module Features
      class TestCasterFeatures < Minitest::Test
        def setup
          @char = Character.new(name: 'Hero', statblock: Statblock.new(name: 'Hero'))
        end

        def test_diviner_portent
          feature = Portent.new
          feature.on_turn_start({ character: @char })
          feature.instance_variable_set(:@rolls, [20])
          bonus = feature.on_attack_roll({ raw_roll: 5 })

          assert_equal 15, bonus
        end

        def test_warding_flare
          feature = WardingFlare.new
          @char.statblock.resources.set_max(:warding_flare, 1)
          roll_data = { total: 15, raw: 10, modifier: 5, rolls: [10], advantage: false, disadvantage: false }
          new_roll = feature.on_after_attack_roll({ defender: @char }, roll_data)

          assert new_roll[:disadvantage]
        end

        def test_bardic_inspiration
          assert BardicInspiration.new
        end

        def test_innate_sorcery
          assert InnateSorcery.new
        end

        def test_divine_spark
          assert DivineSpark.new
        end

        def test_wild_shape
          assert WildShape.new
        end
      end
    end
  end
end
