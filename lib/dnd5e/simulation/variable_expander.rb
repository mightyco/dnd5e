# frozen_string_literal: true

module Dnd5e
  module Simulation
    # Expands a variable preset JSON into a list of specific simulation payloads.
    class VariableExpander
      def expand(preset)
        variables = preset['variables'] || {}
        return [preset] if variables.empty?

        keys = variables.keys
        values_product = variables.values[0].product(*variables.values[1..])

        values_product.map do |values|
          mapping = keys.zip(values).to_h
          apply_mapping(preset, mapping)
        end
      end

      private

      def apply_mapping(preset, mapping)
        new_preset = preset.dup
        new_preset.delete('variables')
        # Inject the specific mapping for the UI to know which point in the sweep this is
        new_preset['sweep_parameters'] = mapping

        json_str = new_preset.to_json
        mapping.each do |key, val|
          json_str.gsub!("\"{{#{key}}}\"", val.is_a?(String) ? "\"#{val}\"" : val.to_s)
          json_str.gsub!("{{#{key}}}", val.to_s)
        end

        JSON.parse(json_str)
      end
    end
  end
end
