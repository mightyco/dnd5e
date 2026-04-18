# frozen_string_literal: true

module Dnd5e
  module Core
    # Initialization logic for Statblock to keep the main class small.
    module StatblockInitialization
      private

      def initialize_from_options(opt)
        stats = Statblock::DEFAULT_STATS.merge(opt)
        %i[strength dexterity constitution intelligence wisdom charisma hit_die level extra_attacks speed
           crit_threshold heroic_inspiration damage_taken damage_dealt size altitude].each do |k|
          instance_variable_set("@#{k}", stats[k])
        end
        @armor_class = opt[:armor_class]
        @saving_throw_proficiencies = opt[:saving_throw_proficiencies] || []
        @equipped_armor = opt[:equipped_armor]
        @equipped_shield = opt[:equipped_shield]
        @conditions = opt[:conditions] || []
      end
    end
  end
end
