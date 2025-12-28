# frozen_string_literal: true

require 'json'
require 'singleton'
require_relative 'spell'
require_relative 'condition'
require_relative 'magic_item'
require_relative 'mechanic'

module Dnd5e
  module Core
    # Singleton repository for accessing ingested rules data.
    # It acts as a read-only interface to the cached JSON data.
    class RuleRepository
      include Singleton

      CACHE_FILE = 'data/rules_cache.json'

      attr_reader :spells, :conditions, :items, :mechanics, :class_tables

      def initialize
        @spells = {}
        @conditions = {}
        @items = {}
        @mechanics = {}
        @class_tables = {}
        load_data if File.exist?(CACHE_FILE)
      end

      # Reloads data from the cache file.
      def reload!
        load_data
      end

      # Checks if the repository has loaded data.
      # @return [Boolean]
      def loaded?
        !@spells.empty? || !@class_tables.empty?
      end

      private

      def load_data
        return reset_data unless File.exist?(CACHE_FILE)

        data = JSON.parse(File.read(CACHE_FILE), symbolize_names: true)

        @spells = map_collection(data[:spells], Spell)
        @conditions = map_collection(data[:conditions], Condition)
        @items = map_collection(data[:items], MagicItem)
        @mechanics = map_collection(data[:mechanics], Mechanic)
        @class_tables = data[:class_tables] || {}
      rescue JSON::ParserError => e
        warn "Failed to parse rules cache: #{e.message}"
      end

      def reset_data
        @spells = {}
        @conditions = {}
        @items = {}
        @mechanics = {}
        @class_tables = {}
      end

      def map_collection(collection, klass)
        return {} unless collection

        collection.each_with_object({}) do |item_data, hash|
          # We assume the models support keyword arguments matching the JSON structure.
          # We might need a factory or explicit mapping if keys drift.
          obj = klass.new(**item_data)
          hash[obj.name] = obj
        end
      end
    end
  end
end
