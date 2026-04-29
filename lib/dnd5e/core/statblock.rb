# frozen_string_literal: true

require_relative 'resource_pool'
require_relative 'proficiency'
require_relative 'condition_manager'
require_relative 'statblock_initialization'
require_relative 'statblock_mechanics'

module Dnd5e
  module Core
    # Represents a character's stat block in the D&D 5e system.
    class Statblock
      include StatblockInitialization
      include StatblockMechanics

      DEFAULT_STATS = {
        strength: 10, dexterity: 10, constitution: 10, intelligence: 10, wisdom: 10, charisma: 10,
        hit_die: 'd8', level: 1, extra_attacks: 0, resources: {}, speed: 30, crit_threshold: 20,
        heroic_inspiration: false, damage_taken: 0, damage_dealt: 0, size: :medium, altitude: 0,
        hp_bonus_per_level: 0
      }.freeze

      def initialize(name:, **options)
        @name = name
        initialize_from_options(options)
        @resources = ResourcePool.new(options[:resources] || {})
        @hp_bonus_per_level = options[:hp_bonus_per_level] || 0
        @max_hp = options[:hit_points] || calculate_hit_points
        @hit_points = options[:hit_points] || @max_hp
        @condition_manager = ConditionManager.new
        sync_initial_conditions
      end

      def add_condition(name, options = {})
        @condition_manager.add(name, options)
      end

      def remove_condition(name)
        @condition_manager.remove(name)
      end

      def condition?(name)
        @condition_manager.active?(name)
      end

      def prone?
        condition?(:prone)
      end

      def sync_initial_conditions
        return unless defined?(@conditions) && @conditions

        @conditions.each { |c| add_condition(c) }
      end

      def on_character_init(character)
        @character = character
      end

      def armor_class
        return @armor_class if defined?(@armor_class) && @armor_class

        base = if !@equipped_armor && unarmored_class?
                 calculate_unarmored_ac
               else
                 calculate_base_ac
               end

        base += @equipped_shield.base_ac if @equipped_shield
        base
      end

      attr_writer :armor_class

      attr_accessor :strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma, :hit_points,
                    :saving_throw_proficiencies, :equipped_armor, :equipped_shield, :extra_attacks,
                    :resources, :speed, :crit_threshold, :heroic_inspiration, :damage_taken,
                    :damage_dealt, :altitude, :hp_bonus_per_level, :max_hp
      attr_reader :name, :hit_die, :class_levels, :condition_manager, :size

      def level
        @class_levels.values.sum
      end

      def calculate_hit_points
        return @max_hp if defined?(@max_hp) && @max_hp

        sides = @hit_die.sub('d', '').to_i
        base = sides + ability_modifier(:constitution) + @hp_bonus_per_level
        current_level = level
        return base if current_level == 1

        growth = ((sides + 1) / 2.0).ceil + ability_modifier(:constitution) + @hp_bonus_per_level
        base + (growth * (current_level - 1))
      end

      def level_up(class_name = :character)
        @class_levels[class_name.to_sym] ||= 0
        @class_levels[class_name.to_sym] += 1

        # Grow HP based on class hit die if possible
        # For now, we still use @hit_die for the base class,
        # but we could improve this to use a map of class -> hit_die
        sides = hit_die_for_class(class_name)
        growth = ((sides + 1) / 2.0).ceil + ability_modifier(:constitution) + @hp_bonus_per_level
        @max_hp += growth
        @hit_points = @max_hp
      end

      def hit_die_for_class(class_name)
        case class_name.to_sym
        when :barbarian then 12
        when :fighter, :paladin, :ranger then 10
        when :bard, :cleric, :druid, :monk, :rogue, :warlock then 8
        when :wizard, :sorcerer then 6
        else hit_die_sides
        end
      end

      def deep_copy
        copy = dup
        copy.instance_variable_set(:@class_levels, @class_levels.dup)
        copy.instance_variable_set(:@saving_throw_proficiencies, @saving_throw_proficiencies.dup)
        copy.instance_variable_set(:@resources, @resources.deep_copy) if @resources.respond_to?(:deep_copy)
        copy.instance_variable_set(:@condition_manager, @condition_manager.dup)
        copy
      end
    end
  end
end
