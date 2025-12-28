# frozen_string_literal: true

module Dnd5e
  module Core
    # Manages a collection of features and executes hooks.
    class FeatureManager
      attr_reader :features

      def initialize(features = [])
        @features = features
      end

      # Executes a hook on all features.
      # @param hook_name [Symbol] The name of the hook method to call.
      # @param context [Hash] Context to pass to the hook.
      # @param initial_value [Object] The starting value to be modified.
      # @return [Object] The final value after all features have modified it.
      def apply_hook(hook_name, context, initial_value)
        @features.reduce(initial_value) do |value, feature|
          context[:current_value] = value
          feature.send(hook_name, context) || value
        end
      end

      # Specialized hook for modifiers (additive).
      def apply_modifier_hook(hook_name, context, initial_mod)
        @features.reduce(initial_mod) do |mod, feature|
          mod + feature.send(hook_name, context)
        end
      end

      # Specialized hook for accumulating lists (e.g. extra dice).
      def apply_list_hook(hook_name, context)
        @features.flat_map do |feature|
          feature.send(hook_name, context)
        end
      end
    end
  end
end
