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
    when :condition_applied
      puts "  CONDITION: #{data[:condition]} applied to #{data[:target].name}"
    when :combat_end
      puts "\nWINNER: #{data[:winner].name}"
    end
  end
end

abilities = { strength: 18, dexterity: 18, wisdom: 18, charisma: 18, constitution: 18, intelligence: 18 }
builder = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero').as_ranger(level: 5, subclass: :hunter, abilities: abilities)
hero = builder.build
monster_builder = Dnd5e::Builders::MonsterBuilder.new(name: 'Bugbear')
monsters = 2.times.map { |i| monster_builder.as_bugbear.build.tap { |m| m.instance_variable_set(:@name, "Bugbear #{i+1}") } }

teams = [Dnd5e::Core::Team.new(name: 'Heroes', members: [hero]), Dnd5e::Core::Team.new(name: 'Monsters', members: monsters)]
scenario = Dnd5e::Simulation::Scenario.new(teams: teams, num_simulations: 1)

module Dnd5e
  module Core
    class TeamCombat
      alias_method :orig_init, :initialize
      def initialize(*args, **kwargs)
        orig_init(*args, **kwargs)
        @grid.clear
        @grid.place(@teams[0].members[0], Point2D.new(0, 0))
        @grid.place(@teams[1].members[0], Point2D.new(50, 0))
        @grid.place(@teams[1].members[1], Point2D.new(50, 5))
        add_observer(DebugObserver.new)
      end
    end
  end
end

Dnd5e::Simulation::Runner.new(scenario: scenario, result_handler: Dnd5e::Simulation::JSONCombatResultHandler.new).run
