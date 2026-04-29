# frozen_string_literal: true

module Dnd5e
  module Core
    # Initialization logic for Statblock to keep the main class small.
    module StatblockInitialization
      private

      def initialize_from_options(opt)
        stats = Statblock::DEFAULT_STATS.merge(opt)
        initialize_basic_stats(stats)
        initialize_class_levels(opt, stats)
        @armor_class = opt[:armor_class]
        @saving_throw_proficiencies = opt[:saving_throw_proficiencies] || []
        @equipped_armor = opt[:equipped_armor]
        @equipped_shield = opt[:equipped_shield]
        @conditions = opt[:conditions] || []
      end

      def initialize_basic_stats(stats)
        %i[strength dexterity constitution intelligence wisdom charisma hit_die extra_attacks speed
           crit_threshold heroic_inspiration damage_taken damage_dealt size altitude].each do |k|
          instance_variable_set("@#{k}", stats[k])
        end
      end

      def initialize_class_levels(opt, stats)
        @class_levels = opt[:class_levels] || stats[:class_levels] || {}
        return unless @class_levels.empty?

        level = opt[:level] || stats[:level]
        return unless level

        @class_levels[:character] = level
      end

      def hit_die_sides
        @hit_die.delete('d').to_i
      end
    end
  end
end
