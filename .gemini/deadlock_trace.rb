require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'
require 'timeout'

module Dnd5e::Core
  class Combat
    def run_rounds
      puts "RUN ROUNDS START (R#{@round_counter})"
      until over?
        puts "  CHECKING TIMEOUT"
        check_timeout
        puts "  PROCESSING TURN CYCLE"
        process_turn_cycle
      end
      puts "RUN ROUNDS END"
    end
  end
end

abilities = { strength: 18, dexterity: 18, constitution: 18, intelligence: 18, wisdom: 18, charisma: 18 }
builder = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero').as_ranger(level: 5, subclass: :hunter, abilities: abilities)
hero = builder.build
monster_builder = Dnd5e::Builders::MonsterBuilder.new(name: 'Bugbear')
monsters = [monster_builder.as_bugbear.build]
teams = [Dnd5e::Core::Team.new(name: 'Heroes', members: [hero]), Dnd5e::Core::Team.new(name: 'Monsters', members: monsters)]
scenario = Dnd5e::Core::TeamCombat.new(teams: teams, max_rounds: 1)

begin
  scenario.run_combat
rescue Exception => e
  puts "ERROR: #{e.message}"
end
