# frozen_string_literal: true

module Dnd5e
  module Builders
    module ClassLogic
      # Logic for building Monk characters.
      module MonkLogic
        private

        def build_monk_statblock(level, abilities)
          Core::Statblock.new(
            name: @name, strength: abilities[:strength], dexterity: abilities[:dexterity],
            constitution: abilities[:constitution], intelligence: abilities[:intelligence],
            wisdom: abilities[:wisdom], charisma: abilities[:charisma], hit_die: 'd8',
            level: level, saving_throw_proficiencies: %i[strength dexterity],
            equipped_armor: nil, # Unarmored Defense
            extra_attacks: (level >= 5 ? 1 : 0),
            resources: { focus_points: (level >= 2 ? level : 0) }
          )
        end

        def add_monk_features(level)
          with_feature(Core::Features::MartialArts.new)
          with_feature(Core::Features::FlurryOfBlows.new) if level >= 2
          @subclass_strategy = Core::Strategies::MonkStrategy.new
        end
      end
    end
  end
end
