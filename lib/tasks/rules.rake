# frozen_string_literal: true

require 'json'
require_relative '../dnd5e/core/rule_repository'
require_relative '../dnd5e/ingest/rule_ingestor'

namespace :rules do
  desc 'Ingest rules from text files and build the JSON cache'
  task :build do
    puts 'Building rules cache...'
    
    ingestor = Dnd5e::Ingest::RuleIngestor.new
    # Ingest from the standard reference directory and SRD
    rules = ingestor.ingest(['rules_reference', 'srd_reference'])
    
    # Serialize rules to simple hash structure
    # This requires our model objects to be serializable or we map them manually here
    serializable_rules = {
      spells: rules[:spells].map { |s| object_to_hash(s) },
      conditions: rules[:conditions].map { |c| object_to_hash(c) },
      items: rules[:items].map { |i| object_to_hash(i) },
      mechanics: rules[:mechanics].map { |m| object_to_hash(m) }
    }

    File.write(Dnd5e::Core::RuleRepository::CACHE_FILE, JSON.pretty_generate(serializable_rules))
    puts "Cache written to #{Dnd5e::Core::RuleRepository::CACHE_FILE}"
    puts 'Stats:'
    puts "  Spells: #{serializable_rules[:spells].count}"
    puts "  Conditions: #{serializable_rules[:conditions].count}"
    puts "  Items: #{serializable_rules[:items].count}"
  end

  desc 'Clear the rules cache'
  task :clean do
    FileUtils.rm_f(Dnd5e::Core::RuleRepository::CACHE_FILE)
    puts 'Rules cache cleared.'
  end
end

def object_to_hash(obj)
  obj.instance_variables.each_with_object({}) do |var, hash|
    key = var.to_s.delete('@').to_sym
    hash[key] = obj.instance_variable_get(var)
  end
end
