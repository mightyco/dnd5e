# frozen_string_literal: true

require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/statblock'
require_relative '../lib/dnd5e/experiments/experiment'

module Dnd5e
  module Examples
    # An example experiment running a simulation.
    class SimulationExample
      def self.run
        experiment = Experiments::Experiment.new(name: 'Level 1 Fighter vs Level 1 Monster')
                                            .simulations_per_step(100)
                                            .independent_variable(:level, values: [1])
                                            .control_group { |params| create_control_team(params) }
                                            .test_group { |params| create_test_team(params) }

        experiment.run
      end

      def self.create_control_team(_params)
        hero = Builders::CharacterBuilder.new(name: 'Hero')
                                         .as_fighter
                                         .build
        Core::Team.new(name: 'Heroes', members: [hero])
      end

      def self.create_test_team(_params)
        monster = Builders::MonsterBuilder.new(name: 'Monster')
                                          .as_goblin
                                          .build
        Core::Team.new(name: 'Monsters', members: [monster])
      end
    end
  end
end

Dnd5e::Examples::SimulationExample.run
