# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/dnd5e/core/combat'
require_relative '../../lib/dnd5e/core/team'
require_relative '../../lib/dnd5e/builders/character_builder'
require_relative '../../lib/dnd5e/builders/monster_builder'

class TestTimeoutLoop < Minitest::Test
  def test_combat_loop_efficiency
    hero = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero').as_fighter(level: 5).build
    monster = Dnd5e::Builders::MonsterBuilder.new(name: 'Goblin').as_goblin.build

    combat = Dnd5e::Core::Combat.new(combatants: [hero, monster], max_rounds: 100, distance: 100)

    puts 'Starting Manual Loop...'
    run_manual_loop(combat, hero, monster)
  end

  private

  def run_manual_loop(combat, hero, monster)
    while !combat.over? && combat.instance_variable_get(:@round_counter) < 10
      log_round_state(combat, hero, monster)
      execute_combatant_turns(combat, [hero, monster])
      combat.instance_variable_set(:@round_counter, combat.instance_variable_get(:@round_counter) + 1)
    end
  end

  def log_round_state(combat, hero, monster)
    h_pos = combat.grid.find_position(hero)
    m_pos = combat.grid.find_position(monster)
    dist = combat.grid.distance(h_pos, m_pos)
    puts "\nRound #{combat.instance_variable_get(:@round_counter)}: Dist #{dist}ft | " \
         "Hero #{h_pos.x},#{h_pos.y} | Goblin #{m_pos.x},#{m_pos.y}"
  end

  def execute_combatant_turns(combat, combatants)
    combatants.each { |c| log_combatant_movement(c, combat) }
  end

  def log_combatant_movement(combatant, combat)
    puts "#{combatant.name} movement available: #{combatant.turn_context.movement_available?}"
    combatant.strategy.execute_turn(combatant, combat)
    log_final_pos(combatant, combat)
    combatant.turn_context.reset!(combatant.statblock.movement_speed)
  end

  def log_final_pos(combatant, combat)
    used = combatant.turn_context.instance_variable_get(:@movement_used)
    pos = combat.grid.find_position(combatant)
    puts "#{combatant.name} moved to #{pos.x},#{pos.y} | movement used: #{used}"
  end
end
