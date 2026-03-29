# frozen_string_literal: true

require 'json-schema'

# Configure json-schema to avoid MultiJSON deprecation
JSON::Validator.use_multi_json = false
