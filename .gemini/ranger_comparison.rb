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
        @teams[1].members.each_with_index { |m, i| @grid.place(m, Point2D.new(100, i * 5)) }
      end
    end
  end
end

def run_bench(feature_name, num_bugbears)
  abilities = { strength: 18, dexterity: 18, constitution: 18, intelligence: 18, wisdom: 18, charisma: 18 }
  builder = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero').as_ranger(level: 5, subclass: :hunter, abilities: abilities)
  hero = builder.build
  
  # Filter features to only include the one we're testing
  hero.feature_manager.instance_variable_get(:@features).reject! do |f| 
    (f.name == 'Colossus Slayer' || f.name == 'Horde Breaker') && f.name != feature_name 
  end

  monster_builder = Dnd5e::Builders::MonsterBuilder.new(name: 'Bugbear')
  monsters = num_bugbears.times.map { monster_builder.as_bugbear.build }
  
  teams = [Dnd5e::Core::Team.new(name: 'Heroes', members: [hero]), Dnd5e::Core::Team.new(name: 'Monsters', members: monsters)]
  scenario = Dnd5e::Simulation::Scenario.new(teams: teams, num_simulations: 100)
  handler = Dnd5e::Simulation::JSONCombatResultHandler.new
  Dnd5e::Simulation::Runner.new(scenario: scenario, result_handler: handler).run
  
  combats = JSON.parse(handler.to_json)
  win_rate = combats.count { |c| c['winner'] == 'Heroes' }.to_f / combats.length * 100
  avg_rounds = combats.any? ? combats.sum { |c| c['rounds'].length }.to_f / combats.length : 0
  [win_rate, avg_rounds]
end

puts "Ranger Hunter Comparison (100ft Start)"
puts "======================================"
[1, 2, 3].each do |count|
  cs_win, cs_rnd = run_bench('Colossus Slayer', count)
  hb_win, hb_rnd = run_bench('Horde Breaker', count)
  puts "vs #{count} Bugbears:"
  puts "  Colossus Slayer: #{cs_win.round(1)}% (Avg #{cs_rnd.round(1)} rounds)"
  puts "  Horde Breaker:   #{hb_win.round(1)}% (Avg #{hb_rnd.round(1)} rounds)"
end
