require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'

module Dnd5e
  module Core
    class TeamCombat
      alias_method :orig_init, :initialize
      def initialize(*args, **kwargs)
        orig_init(*args, **kwargs)
        @grid.clear
        @grid.place(@teams[0].members[0], Point2D.new(0, 0))
        @teams[1].members.each_with_index do |m, i|
          @grid.place(m, Point2D.new(100, i * 5))
        end
      end
    end
  end
end

def run_stress_test(num_bugbears)
  abilities = { strength: 18, dexterity: 18, constitution: 18, intelligence: 18, wisdom: 18, charisma: 18 }
  builder = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero').as_ranger(level: 5, subclass: :hunter, abilities: abilities)
  hero = builder.build
  
  monster_builder = Dnd5e::Builders::MonsterBuilder.new(name: 'Bugbear')
  monsters = num_bugbears.times.map { monster_builder.as_bugbear.build }
  
  teams = [Dnd5e::Core::Team.new(name: 'Heroes', members: [hero]), Dnd5e::Core::Team.new(name: 'Monsters', members: monsters)]
  scenario = Dnd5e::Simulation::Scenario.new(teams: teams, num_simulations: 100)
  handler = Dnd5e::Simulation::JSONCombatResultHandler.new
  Dnd5e::Simulation::Runner.new(scenario: scenario, result_handler: handler).run
  
  combats = JSON.parse(handler.to_json)
  combats.count { |c| c['winner'] == 'Heroes' }.to_f / combats.length * 100
end

puts "Ranger (Hunter) Stress Test (Realistic 100ft Start)"
puts "=================================================="
[1, 2, 3].each do |count|
  win_rate = run_stress_test(count)
  puts "vs #{count} Bugbears -> #{win_rate}%"
end
