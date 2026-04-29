# frozen_string_literal: true

module Dnd5e
  module Builders
    # Helpers for building class levels and resources.
    module ClassBuilderHelpers
      private

      def add_class_levels(class_name, level, abilities, **)
        abilities = merge_abilities(abilities)
        if @statblock
          level.times { @statblock.level_up(class_name) }
        else
          initialize_new_statblock(class_name, level, abilities, **)
        end

        # Ensure multiclass-capable resource calculation is used even for first class
        @statblock.resources = Core::ResourcePool.new(recalculate_all_resources)
      end

      def initialize_new_statblock(class_name, level, abilities, **opts)
        method_name = "build_#{class_name}_statblock"
        @statblock = opts.any? ? send(method_name, level, abilities, **opts) : send(method_name, level, abilities)

        # Ensure class_levels uses the specific class instead of generic :character
        if @statblock.class_levels.key?(:character)
          @statblock.instance_variable_set(:@class_levels, { class_name.to_sym => level })
        end

        # Ensure features for the class are added
        feature_method = "add_#{class_name}_features"
        send(feature_method, level) if respond_to?(feature_method, true)
      end

      def recalculate_all_resources
        levels = @statblock.class_levels
        # Aggregate all resources
        res = if levels.size > 1
                SpellSlotCalculator.calculate_multiclass(levels)
              else
                calculate_single_class_slots(levels)
              end

        # Merge class-specific resources (Rage, etc)
        res.merge!(calculate_class_resources(levels))
        res
      end

      def calculate_single_class_slots(levels)
        class_key, level = levels.first
        class_name = map_class_name(class_key)
        SpellSlotCalculator.calculate(class_name, level)
      end

      def map_class_name(key)
        key.to_s.split('_').map(&:capitalize).join
      end

      def calculate_class_resources(levels)
        res = {}
        res.merge!(calculate_fighter_resources(levels[:fighter])) if levels[:fighter]
        res[:rage] = calculate_rage_uses(levels[:barbarian]) if levels[:barbarian]
        res[:focus_points] = levels[:monk] if levels[:monk] && levels[:monk] >= 2
        res.merge!(calculate_caster_resources(levels))
        res
      end

      def calculate_caster_resources(levels)
        res = {}
        res[:channel_divinity] = 2 if channel_divinity?(levels)
        res[:bardic_inspiration] = Core::Proficiency.calculate(levels.values.sum) if levels[:bard]
        res[:wild_shape] = 2 if (levels[:druid] || 0) >= 2
        res[:sorcery_points] = levels[:sorcerer] if (levels[:sorcerer] || 0) >= 2
        res
      end

      def channel_divinity?(levels)
        (levels[:paladin] || 0) >= 3 || (levels[:cleric] || 0) >= 2
      end
    end
  end
end
