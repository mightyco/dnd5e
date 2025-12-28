# frozen_string_literal: true

require_relative '../lib/dnd5e/core/team_combat'
require_relative '../lib/dnd5e/core/character'
require_relative '../lib/dnd5e/core/monster'
require_relative '../lib/dnd5e/core/statblock'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/combat_statistics'
require_relative '../lib/dnd5e/simulation/scenario'
require_relative '../lib/dnd5e/builders'

require 'logger'

module Dnd5e
  module Examples
    # Core domain logic examples.
    module Core
    end

    # Example of running a team combat.
    class TeamCombatExample
      def self.run
        new.run_combat
      end

      def run_combat
        Logger.new($stdout)

        heroes = create_hero_team
        goblins = create_goblin_team

        # Create a team combat
        combat = Dnd5e::Core::TeamCombat.new(teams: [heroes, goblins])

        # Add logger if desired (TeamCombat uses observers or internal logging)
        # Assuming TeamCombat has a way to attach logger or uses standard logging.
        # For now, just running it.

        combat.run_combat

        puts "Winner: #{combat.winner.name}"
      end

      private

      def create_hero_team
        sword = Dnd5e::Core::Attack.new(name: 'Sword', damage_dice: Dnd5e::Core::Dice.new(1, 8),
                                        relevant_stat: :strength)
        hero_stats = Dnd5e::Core::Statblock.new(name: 'Hero', strength: 16, dexterity: 10, constitution: 14,
                                                hit_die: 'd10', level: 1)

        hero1 = Dnd5e::Core::Character.new(name: 'Hero 1', statblock: hero_stats.deep_copy, attacks: [sword])
        hero2 = Dnd5e::Core::Character.new(name: 'Hero 2', statblock: hero_stats.deep_copy, attacks: [sword])

        Dnd5e::Core::Team.new(name: 'Heroes', members: [hero1, hero2])
      end

      def create_goblin_team
        bite = Dnd5e::Core::Attack.new(name: 'Bite', damage_dice: Dnd5e::Core::Dice.new(1, 6),
                                       relevant_stat: :dexterity)
        goblin_stats = Dnd5e::Core::Statblock.new(name: 'Goblin', strength: 8, dexterity: 14, constitution: 10,
                                                  hit_die: 'd6', level: 1)

        goblin1 = Dnd5e::Core::Monster.new(name: 'Goblin 1', statblock: goblin_stats.deep_copy, attacks: [bite])
        goblin2 = Dnd5e::Core::Monster.new(name: 'Goblin 2', statblock: goblin_stats.deep_copy, attacks: [bite])

        Dnd5e::Core::Team.new(name: 'Goblins', members: [goblin1, goblin2])
      end
    end
  end
end

Dnd5e::Examples::TeamCombatExample.run if __FILE__ == $PROGRAM_NAME
