# frozen_string_literal: true

require 'json'
require_relative '../dnd5e/core/rule_repository'
require_relative '../dnd5e/ingest/rule_ingestor'

namespace :rules do
  desc 'Ingest rules from text files and build the JSON cache'
  task :build do
    puts 'Building rules cache...'
    ingestor = Dnd5e::Ingest::RuleIngestor.new
    rules = ingestor.ingest(%w[rules_reference srd_reference])

    serializable_rules = build_serializable_rules(rules)
    save_rules_cache(serializable_rules)
    print_rules_stats(serializable_rules)
  end

  desc 'Clear the rules cache'
  task :clean do
    FileUtils.rm_f(Dnd5e::Core::RuleRepository::CACHE_FILE)
    puts 'Rules cache cleared.'
  end
end

def build_serializable_rules(rules)
  {
    spells: rules[:spells].map { |s| object_to_hash(s) },
    conditions: rules[:conditions].map { |c| object_to_hash(c) },
    items: rules[:items].map { |i| object_to_hash(i) },
    mechanics: rules[:mechanics].map { |m| object_to_hash(m) },
    class_tables: rules[:class_tables]
  }
end

def save_rules_cache(rules)
  FileUtils.mkdir_p(File.dirname(Dnd5e::Core::RuleRepository::CACHE_FILE))
  File.write(Dnd5e::Core::RuleRepository::CACHE_FILE, JSON.pretty_generate(rules))
  puts "Cache written to #{Dnd5e::Core::RuleRepository::CACHE_FILE}"
end

def print_rules_stats(rules)
  puts 'Stats:'
  puts "  Spells: #{rules[:spells].count}"
  puts "  Conditions: #{rules[:conditions].count}"
  puts "  Items: #{rules[:items].count}"
  puts "  Class Tables: #{rules[:class_tables].count}"
end

def object_to_hash(obj)
  obj.instance_variables.each_with_object({}) do |var, hash|
    key = var.to_s.delete('@').to_sym
    hash[key] = obj.instance_variable_get(var)
  end
end
