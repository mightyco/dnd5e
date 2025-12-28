# frozen_string_literal: true

require_relative '../lib/dnd5e/ingest/rule_ingestor'

puts 'Testing Rule Ingestor...'
ingestor = Dnd5e::Ingest::RuleIngestor.new

puts 'Ingesting from test/fixtures/spells.txt...'
rules = ingestor.ingest('test/fixtures/spells.txt')

puts "Found #{rules[:spells].count} spells."
rules[:spells].each do |spell|
  puts '----------------------------------------'
  puts "Name: #{spell.name}"
  puts "Level: #{spell.level}"
  puts "School: #{spell.school}"
  puts "Range: #{spell.range}"
  puts "Description: #{spell.description[0..50]}..."
end
