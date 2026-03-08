# frozen_string_literal: true

require_relative 'resource_pool'
require_relative 'proficiency'
require_relative 'condition_manager'

module Dnd5e
  module Core
    # Represents a character's stat block in the D&D 5e system.
    class Statblock
      attr_reader :name, :hit_die, :level, :condition_manager
      attr_accessor :strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma, :hit_points,
                    :saving_throw_proficiencies, :equipped_armor, :equipped_shield,
                    :extra_attacks, :resources, :speed, :crit_threshold, :heroic_inspiration

      DEFAULT_STATS = {
        strength: 10, dexterity: 10, constitution: 10,
        intelligence: 10, wisdom: 10, charisma: 10,
        hit_die: 'd8', level: 1, extra_attacks: 0,
        resources: {}, speed: 30, crit_threshold: 20,
        heroic_inspiration: false
      }.freeze

      def initialize(name:, **options)
        @name = name
        initialize_from_options(options)
        @resources = ResourcePool.new(options[:resources] || {})
        @hit_points = calculate_hit_points
        @condition_manager = ConditionManager.new
        sync_initial_conditions
      end

      def add_condition(name, options = {})
        @condition_manager.add(name, options)
      end

      def remove_condition(name)
        @condition_manager.remove(name)
      end

      def conditions
        @condition_manager.conditions.keys
      end

      def condition?(name)
        @condition_manager.active?(name)
      end

      def prone?
        condition?(:prone)
      end

      def sync_initial_conditions
        @conditions.each { |c| @condition_manager.add(c) }
      end

      def armor_class
        return @armor_class if defined?(@armor_class) && @armor_class

        dex_mod = ability_modifier(:dexterity)
        base = @equipped_armor ? @equipped_armor.calculate_ac(dex_mod) : 10 + dex_mod
        base += @equipped_shield.base_ac if @equipped_shield
        base
      end

      attr_writer :armor_class

      def ability_modifier(ability)
        score = instance_variable_get("@#{ability}")
        raise ArgumentError, "Invalid ability: #{ability}" unless score

        (score - 10) / 2
      end

      def proficient_in_save?(ability)
        @saving_throw_proficiencies.include?(ability)
      end

      def save_modifier(ability)
        mod = ability_modifier(ability)
        mod += proficiency_bonus if proficient_in_save?(ability)
        mod
      end

      def take_damage(damage)
        raise ArgumentError, 'Damage must be non-negative' if damage.negative?

        @hit_points = [0, @hit_points - damage].max
      end

      def heal(amount)
        raise ArgumentError, 'Healing amount must be non-negative' if amount.negative?

        @hit_points = [calculate_hit_points, @hit_points + amount].min
      end

      def alive?
        @hit_points.positive?
      end

      def calculate_hit_points
        hit_die_sides = @hit_die.sub('d', '').to_i
        base_hp = hit_die_sides + ability_modifier(:constitution)
        return base_hp if @level == 1

        additional_hp_per_level = ((hit_die_sides + 1) / 2.0).ceil + ability_modifier(:constitution)
        base_hp + (additional_hp_per_level * (@level - 1))
      end

      def level_up
        @level += 1
        @hit_points = calculate_hit_points
      end

      def proficiency_bonus
        Proficiency.calculate(@level)
      end

      def deep_copy
        Marshal.load(Marshal.dump(self))
      end

      private

      def initialize_from_options(options)
        stats = DEFAULT_STATS.merge(options)
        %i[strength dexterity constitution intelligence wisdom charisma hit_die level extra_attacks speed
           crit_threshold heroic_inspiration].each do |key|
          instance_variable_set("@#{key}", stats[key])
        end
        @armor_class = options[:armor_class]
        @saving_throw_proficiencies = options[:saving_throw_proficiencies] || []
        @equipped_armor = options[:equipped_armor]
        @equipped_shield = options[:equipped_shield]
        @conditions = options[:conditions] || []
      end
    end
  end
end
