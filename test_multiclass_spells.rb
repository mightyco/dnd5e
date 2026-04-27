# frozen_string_literal: true

require_relative 'lib/dnd5e/builders/spell_slot_calculator'

puts 'Running Multi-Class Spell Test...'

test_cases = [
  { levels: { wizard: 3 }, expected: { lvl1_slots: 4, lvl2_slots: 2 } },
  { levels: { cleric: 2, wizard: 1 }, expected: { lvl1_slots: 4, lvl2_slots: 2 } },
  { levels: { paladin: 2, ranger: 2 }, expected: { lvl1_slots: 3 } }, # (2/2 + 2/2) = 2nd level caster
  { levels: { bard: 2, paladin: 3 }, expected: { lvl1_slots: 4, lvl2_slots: 2 } } # (2 + 3/2.floor) = 3rd level caster
]

test_cases.each do |tc|
  print "Testing #{tc[:levels]}... "
  actual = Dnd5e::Builders::SpellSlotCalculator.calculate_multiclass(tc[:levels])
  if actual == tc[:expected]
    puts 'SUCCESS'
  else
    puts "FAILURE: Expected #{tc[:expected]}, got #{actual}"
    exit 1
  end
end

puts 'ALL SPELL TESTS PASSED.'
