# frozen_string_literal: true

require 'json'
require 'json-schema'

module Dnd5e
  module Core
    # Registry for UI schemas and dynamic component definitions.
    class SchemaRegistry
      SCHEMA_PATH = File.expand_path('../../../data/schemas/ui_schema.json', __dir__)
      META_SCHEMA_PATH = File.expand_path('../../../data/schemas/ui_schema_meta.json', __dir__)

      def self.load_ui_schema
        data = JSON.parse(File.read(SCHEMA_PATH))
        validate!(data)
        data
      rescue StandardError => e
        warn "UI Schema validation failed: #{e.message}. Using empty fallback."
        { 'character_fields' => [] }
      end

      def self.validate!(data)
        JSON::Validator.validate!(META_SCHEMA_PATH, data)
      end
    end
  end
end
