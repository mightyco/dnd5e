require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'

class DebugObserver
  def update(event, data)
    case event
    when :round_start
      puts "\n--- ROUND #{data[:round]} ---"
    when :turn_start
      c = data[:combatant]
      pos = c.instance_variable_get(:@combat_context)&.grid&.find_position(c)
      puts "TURN: #{c.name} (HP: #{c.statblock.hit_points}/#{c.statblock.max_hp}) at #{pos}"
    when :move_resolved
      puts "  MOVE: #{data[:combatant].name} -> #{data[:position]}"
    when :attack
      puts "  ATTACK: #{data[:attacker].name} vs #{data[:defender].name}"
    when :attack_resolved
      res = data[:result]
      puts "    Roll: #{res.attack_roll} vs AC #{res.target_ac} | Hit: #{res.success} | Damage: #{res.damage}"
    when :resource_used
      puts "  RESOURCE: #{data[:combatant].name} used #{data[:resource]}"
    when :condition_applied
      puts "  CONDITION: #{data[:condition]} applied to #{data[:target].name}"
    when :combat_end
      puts "\nWINNER: #{data[:winner].name}"
    end
  end
end

builder = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero').as_ranger(level: 5, subclass: :hunter, abilities: { strength: 18, dexterity: 18, wisdom: 18, charisma: 18, constitution: 18, intelligence: 18 })
hero = builder.build

monster_builder = Dnd5e::Builders::MonsterBuilder.new(name: 'Enemy')
monsters = [monster_builder.as_bugbear.build]

# Put them 50ft apart
teams = [Dnd5e::Core::Team.new(name: 'Heroes', members: [hero]), Dnd5e::Core::Team.new(name: 'Monsters', members: monsters)]
scenario = Dnd5e::Simulation::Scenario.new(teams: teams, num_simulations: 1)
handler = Dnd5e::Simulation::JSONCombatResultHandler.new

module Dnd5e
  module Core
    class TeamCombat
      alias_method :orig_init, :initialize
      def initialize(*args, **kwargs)
        orig_init(*args, **kwargs)
        @grid.clear
        @grid.place(@teams[0].members[0], Point2D.new(0, 0))
        @grid.place(@teams[1].members[0], Point2D.new(50, 0))
        add_observer(DebugObserver.new)
      end
    end
  end
end

Dnd5e::Simulation::Runner.new(scenario: scenario, result_handler: handler).run
