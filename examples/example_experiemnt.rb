# frozen_string_literal: true

require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario_builder'
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
    class SimulationExample
      def self.run
        logger = Logger.new($stdout)
        stats = Core::CombatStatistics.new
        str_attack = Core::Attack.new(name: 'Str-Attack', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength)
        dex_attack = Core::Attack.new(name: 'Dex-Attack', damage_dice: Core::Dice.new(1, 8), relevant_stat: :dexterity)

        # Naked warrior simulation. How often does the Str-Team win?
        # Expected result: Dex-Team wins more often.
        str_template = Core::Statblock.new(name: 'Str-Template', strength: 16, dexterity: 10, constitution: 10,
                                           hit_die: 'd10', level: 1)
        dex_template = Core::Statblock.new(name: 'Dex-Template', strength: 10, dexterity: 16, constitution: 10,
                                           hit_die: 'd10', level: 1)

        str_combatant_one = Core::Character.new(name: 'Str-Combatant-One', statblock: str_template,
                                                attacks: [str_attack])
        str_combatant_two = Core::Character.new(name: 'Str-Combatant-Two', statblock: str_template,
                                                attacks: [str_attack])
        dex_combatant_one = Core::Monster.new(name: 'Dex-Combatant-One', statblock: dex_template, attacks: [dex_attack])
        dex_combatant_two = Core::Monster.new(name: 'Dex-Combatant-Two', statblock: dex_template, attacks: [dex_attack])

        str_team = Core::Team.new(name: 'Str-Team', members: [str_combatant_one, str_combatant_two])
        dex_team = Core::Team.new(name: 'Dex-Team', members: [dex_combatant_one, dex_combatant_two])

        scenario = Simulation::ScenarioBuilder.new(num_simulations: 1000)
                                              .with_team(str_team)
                                              .with_team(dex_team)
                                              .build

        runner = Simulation::Runner.new(
          scenario: scenario,
          result_handler: stats,
          logger: logger
        )

        runner.run
        runner.generate_report
      end
    end
  end
end

Dnd5e::Examples::SimulationExample.run
