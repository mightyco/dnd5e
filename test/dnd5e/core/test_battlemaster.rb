# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/features/battle_master'
require_relative '../../../lib/dnd5e/core/strategies/battle_master_strategy'

class TestBattleMaster < Minitest::Test
  def setup
    @statblock = Dnd5e::Core::Statblock.new(name: 'Fighter', level: 3, strength: 16)
    @bm_feature = Dnd5e::Core::Features::BattleMaster.new(level: 3)
    @character = Dnd5e::Core::Character.new(name: 'BM', statblock: @statblock, features: [@bm_feature])
  end

  def test_initialization
    assert_equal 4, @character.statblock.resources.resources[:superiority_dice]
    assert_equal 8, @bm_feature.die_type
  end

  def test_high_level_initialization
    bm_high = Dnd5e::Core::Features::BattleMaster.new(level: 18)
    char_high = Dnd5e::Core::Character.new(name: 'BM High', statblock: @statblock, features: [bm_high])

    assert_equal 6, char_high.statblock.resources.resources[:superiority_dice]
    assert_equal 12, bm_high.die_type
  end

  def test_extra_damage_dice_consumption
    context = { attacker: @character, options: { maneuver: :menacing_attack } }
    dice = @bm_feature.extra_damage_dice(context)

    assert_equal 1, dice.size
    assert_equal 8, dice.first.sides
    assert_equal 3, @character.statblock.resources.resources[:superiority_dice]
  end

  def test_precision_attack_hook
    setup_precision_strategy
    defender = create_defender
    context = { attacker: @character, defender: defender, current_value: { total: 14, raw: 9, modifier: 5 } }

    @character.statblock.resources.instance_variable_set(:@dice_roller_override, 4)
    new_roll_data = @bm_feature.on_after_attack_roll(context)

    assert_equal 18, new_roll_data[:total]
    assert_equal 4, new_roll_data[:precision_attack_bonus]
    assert_equal 3, @character.statblock.resources.resources[:superiority_dice]
  end

  private

  def setup_precision_strategy
    strategy = Dnd5e::Core::Strategies::BattleMasterStrategy.new(use_precision_attack: true)
    @character.strategy = strategy
  end

  def create_defender
    Dnd5e::Core::Character.new(name: 'Enemy',
                               statblock: Dnd5e::Core::Statblock.new(name: 'Enemy', armor_class: 15))
  end
end
