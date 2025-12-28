# frozen_string_literal: true

require_relative 'parsers/spell_parser'
require_relative 'parsers/magic_item_parser'
require_relative 'parsers/condition_parser'
require_relative 'parsers/mechanic_parser'
require_relative 'parsers/class_table_parser'

module Dnd5e
  module Ingest
    # Orchestrates the ingestion of rules from text files.
    class RuleIngestor
      attr_reader :parsers, :rules

      def initialize
        @parsers = []
        @rules = {
          spells: [],
          conditions: [],
          items: [],
          mechanics: [],
          class_tables: {}
        }
        register_default_parsers
      end

      def register_parser(parser)
        @parsers << parser
      end

      # Ingests rules from a file or directory.
      # @param path [String] Path to file or directory.
      def ingest(path)
        paths = path.is_a?(Array) ? path : [path]

        paths.each do |p|
          files = File.directory?(p) ? Dir.glob("#{p}/*.txt") : [p]
          files.each do |file|
            # Enforce UTF-8 encoding
            content = File.read(file, encoding: 'UTF-8')
            process_content(content)
          end
        end
        @rules
      end

      private

      def register_default_parsers
        register_parser(Parsers::SpellParser.new)
        register_parser(Parsers::MagicItemParser.new)
        register_parser(Parsers::ConditionParser.new)
        register_parser(Parsers::MechanicParser.new)
        register_parser(Parsers::ClassTableParser.new)
      end

      def process_content(content)
        @parsers.each do |parser|
          results = parser.parse(content)
          merge_results(results)
        end
      end

      def merge_results(results)
        results.each do |key, values|
          if key == :class_tables
            @rules[key].merge!(values)
          elsif @rules.key?(key)
            @rules[key].concat(values)
          end
        end
      end
    end
  end
end
