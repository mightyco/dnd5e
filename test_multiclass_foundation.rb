# frozen_string_literal: true

require_relative 'lib/dnd5e/core/statblock'
require_relative 'lib/dnd5e/core/proficiency'

puts 'Running Multi-Class Foundation Test...'

begin
  # This should fail or act legacy-style currently
  stat = Dnd5e::Core::Statblock.new(
    name: 'Multiclass Test',
    class_levels: { fighter: 3, rogue: 2 },
    strength: 16, dexterity: 14, constitution: 14,
    intelligence: 10, wisdom: 10, charisma: 10
  )

  total_level = stat.level
  pb = stat.proficiency_bonus

  puts "Total Level: #{total_level}"
  puts "Proficiency Bonus: #{pb}"

  if total_level == 5 && pb == 3
    puts 'SUCCESS: Multi-class level and PB correctly calculated.'
  else
    puts "FAILURE: Expected Level 5, PB +3. Got Level #{total_level}, PB +#{pb}"
    exit 1
  end
rescue StandardError => e
  puts "CAUGHT EXPECTED ERROR or BUG: #{e.message}"
  # If it fails because :class_levels isn't handled yet, that's our baseline.
  exit 1
end
