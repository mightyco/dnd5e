# frozen_string_literal: true

require 'test_helper'
require 'dnd5e/ingest/parsers/spell_parser'

class TestSpellParser < Minitest::Test
  def setup
    @parser = Dnd5e::Ingest::Parsers::SpellParser.new
  end

  def test_parse_single_spell
    result = @parser.parse(fireball_text)
    spells = result[:spells]

    assert_equal 1, spells.length
    verify_fireball_attributes(spells.first)
  end

  def test_parse_multiple_spells
    content = "#{magic_missile_text}\n#{fireball_text}"
    result = @parser.parse(content)

    assert_equal 2, result[:spells].length
    assert_equal 'Magic Missile', result[:spells][0].name
    assert_equal 'Fireball', result[:spells][1].name
  end

  private

  def verify_fireball_attributes(spell)
    assert_equal 'Fireball', spell.name
    assert_equal '3rd-level', spell.level
    assert_equal 'evocation', spell.school
    assert_equal '1 action', spell.casting_time
    assert_equal '150 feet', spell.range
    assert_equal 'V, S, M', spell.components
    assert_equal 'Instantaneous', spell.duration
    assert_equal 'A bright streak flashes from your pointing finger.', spell.description
  end

  def fireball_text
    <<~TEXT
      Fireball
      3rd-level evocation
      Casting Time: 1 action
      Range: 150 feet
      Components: V, S, M
      Duration: Instantaneous
      A bright streak flashes from your pointing finger.
    TEXT
  end

  def magic_missile_text
    <<~TEXT
      Magic Missile
      1st-level evocation
      Casting Time: 1 action
      Range: 120 feet
      Components: V, S
      Duration: Instantaneous
      You create three glowing darts of magical force.
    TEXT
  end
end
