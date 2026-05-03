require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'

class TraceObserver
  def update(event, data)
    case event
    when :turn_start
      puts "TURN: #{data[:combatant].name} (HP: #{data[:combatant].statblock.hit_points})"
    when :attack_resolved
      res = data[:result]
      puts "  ATTACK: #{res[:attacker].name} -> #{res[:defender].name} | ROLL: #{res[:roll]} vs AC #{res[:defender_ac]} | HIT: #{res[:hit]} | DAMAGE: #{res[:damage]} | DESC: #{res[:description]}"
    when :resource_used
      puts "  RESOURCE: #{data[:combatant].name} used #{data[:resource]}"
    when :combat_end
      puts "WINNER: #{data[:winner]}"
    end
  end
end

builder = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero').as_ranger(level: 5, subclass: :hunter, abilities: { dexterity: 18, wisdom: 14, constitution: 14 })
hero = builder.build

monster_builder = Dnd5e::Builders::MonsterBuilder.new(name: 'Enemy')
monsters = [monster_builder.as_bugbear.build]

teams = [Dnd5e::Core::Team.new(name: 'Heroes', members: [hero]), Dnd5e::Core::Team.new(name: 'Monsters', members: monsters)]
scenario = Dnd5e::Simulation::Scenario.new(teams: teams, num_simulations: 1)
handler = Dnd5e::Simulation::JSONCombatResultHandler.new

module Dnd5e
  module Core
    class TeamCombat
      alias_method :orig_init, :initialize
      def initialize(*args, **kwargs)
        orig_init(*args, **kwargs)
        add_observer(TraceObserver.new)
      end
    end
  end
end

Dnd5e::Simulation::Runner.new(scenario: scenario, result_handler: handler).run
