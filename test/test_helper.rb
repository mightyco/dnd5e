# frozen_string_literal: true

unless ENV['MUTANT']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/test/'
  end
end

ARGV.clear if ENV['MUTANT']

require 'minitest/autorun'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/statblock'
require_relative '../lib/dnd5e/core/character'
require_relative '../lib/dnd5e/core/monster'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/dice_roller'
require_relative '../lib/dnd5e/core/combat_attack_handler'
require_relative '../lib/dnd5e/core/combat_result_handler'
require_relative '../lib/dnd5e/core/printing_combat_result_handler'
require_relative '../lib/dnd5e/core/attack_resolver'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/core/rule_repository'

# Load rules once for the environment
repo = Dnd5e::Core::RuleRepository.instance
repo.reload!

puts "Loaded Rules: #{repo.spells.size} Spells, #{repo.class_tables.size} Class Tables"

# Sanity check: Ensure rules are actually loaded
unless repo.loaded?
  puts "\n[FATAL] Rules not loaded in test helper! (Cache: #{Dnd5e::Core::RuleRepository::CACHE_FILE})"
  # Only exit in mutant to avoid breaking standard rake gate if cache is missing but mocked
  exit 1 if ENV['MUTANT']
end
