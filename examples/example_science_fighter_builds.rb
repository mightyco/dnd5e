# frozen_string_literal: true

require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/features/improved_critical'
require_relative '../lib/dnd5e/core/features/battle_master'
require_relative '../lib/dnd5e/core/features/two_weapon_fighting'
require_relative '../lib/dnd5e/core/features/dual_wielder'
require_relative '../lib/dnd5e/core/features/great_weapon_master'
require_relative '../lib/dnd5e/core/strategies/battle_master_strategy'
require_relative '../lib/dnd5e/core/team_combat'
require_relative '../lib/dnd5e/simulation/silent_combat_result_handler'

# Scientific Comparison of Fighter Builds (2024 Rules)
# Variables isolated: Archetype (Champion vs BM) and Build (Dual Wield vs Great Weapon)

def create_base_fighter(name, level)
  Dnd5e::Builders::CharacterBuilder.new(name: name)
                                   .as_fighter(level: level, abilities: { strength: 16, dexterity: 14,
                                                                          constitution: 14 })
end

# --- DUAL WIELD BUILDS (Nick/Vex + Dual Wielder feat) ---

def setup_dual_wield(builder, level)
  builder.with_feature(Dnd5e::Core::Features::TwoWeaponFighting.new)
  builder.with_feature(Dnd5e::Core::Features::DualWielder.new) if level >= 4

  vex_dagger = Dnd5e::Core::Attack.new(name: 'Vex Dagger', damage_dice: Dnd5e::Core::Dice.new(1, 4),
                                       relevant_stat: :strength, mastery: :vex, properties: %i[light finesse])
  nick_dagger = Dnd5e::Core::Attack.new(name: 'Nick Dagger', damage_dice: Dnd5e::Core::Dice.new(1, 4),
                                        relevant_stat: :strength, mastery: :nick, properties: %i[light finesse])
  builder.with_attack(vex_dagger).with_attack(nick_dagger)
end

def create_nick_vex_champion(level)
  builder = create_base_fighter('NickVexChamp', level)
            .with_feature(Dnd5e::Core::Features::ImprovedCritical.new)
  setup_dual_wield(builder, level).build
end

def create_nick_vex_battlemaster(level)
  strategy = Dnd5e::Core::Strategies::BattleMasterStrategy.new(use_precision_attack: true, use_damage_maneuver: true)
  builder = create_base_fighter('NickVexBM', level)
            .with_feature(Dnd5e::Core::Features::BattleMaster.new(level: level))
  setup_dual_wield(builder, level).build.tap { |f| f.strategy = strategy }
end

# --- GREAT WEAPON BUILDS (Graze/Cleave + GWM) ---

def setup_great_weapon(builder, mastery)
  builder.with_feature(Dnd5e::Core::Features::GreatWeaponMaster.new)

  weapon = Dnd5e::Core::Attack.new(name: 'Heavy Weapon', damage_dice: Dnd5e::Core::Dice.new(2, 6),
                                   relevant_stat: :strength, mastery: mastery, properties: %i[heavy two_handed])
  builder.with_attack(weapon)
end

def create_heavy_champion(level)
  builder = create_base_fighter('HeavyChamp', level)
            .with_feature(Dnd5e::Core::Features::ImprovedCritical.new)
  setup_great_weapon(builder, :graze).build
end

def create_heavy_battlemaster(level)
  strategy = Dnd5e::Core::Strategies::BattleMasterStrategy.new(use_precision_attack: true, use_damage_maneuver: true)
  builder = create_base_fighter('HeavyBM', level)
            .with_feature(Dnd5e::Core::Features::BattleMaster.new(level: level))
  setup_great_weapon(builder, :cleave).build.tap { |f| f.strategy = strategy }
end

# --- SIMULATION ENGINE ---

def create_monster_team(level)
  case level
  when 1..2
    3.times.map { |i| Dnd5e::Builders::MonsterBuilder.new(name: "Goblin #{i}").as_goblin.build }
  when 3..4
    [Dnd5e::Builders::MonsterBuilder.new(name: 'Bugbear').as_bugbear.build]
  else
    2.times.map { |i| Dnd5e::Builders::MonsterBuilder.new(name: "Bugbear #{i}").as_bugbear.build }
  end.then { |members| Dnd5e::Core::Team.new(name: 'Monsters', members: members) }
end

def run_experiment(fighter_gen, level, days)
  stats = { damage_dealt: 0, damage_taken: 0, wins: 0, rounds: 0 }
  days.times { run_simulated_day(fighter_gen.call(level), level, stats) }
  report_stats(fighter_gen.call(level).name, stats, days)
end

def run_simulated_day(fighter, level, total_stats)
  reset_fighter_for_day(fighter)
  3.times { |enc| run_encounter_cycle(fighter, level, total_stats, enc) }
  record_daily_stats(fighter, total_stats)
end

def run_encounter_cycle(fighter, level, total_stats, enc)
  fighter.statblock.resources.reset! if enc == 1
  monsters = create_monster_team(level)
  combat = Dnd5e::Core::TeamCombat.new(
    teams: [Dnd5e::Core::Team.new(name: 'Fighter', members: [fighter]), monsters],
    distance: 5
  )
  run_simulation_loop(combat, fighter, monsters, total_stats)
  total_stats[:wins] += 1 if fighter.statblock.alive?
end

def reset_fighter_for_day(fighter)
  fighter.statblock.hit_points = fighter.statblock.calculate_hit_points
  fighter.statblock.damage_dealt = 0
  fighter.statblock.damage_taken = 0
end

def run_simulation_loop(combat, fighter, monsters, total_stats)
  while !combat.over? && total_stats[:rounds] < 10_000_000
    total_stats[:rounds] += 1
    fighter.start_turn
    combat.take_turn(fighter) if fighter.statblock.alive?
    monsters.alive_members.each do |monster|
      monster.start_turn if monster.respond_to?(:start_turn)
      combat.take_turn(monster) if fighter.statblock.alive?
    end
  end
end

def record_daily_stats(fighter, total_stats)
  total_stats[:damage_dealt] += fighter.statblock.damage_dealt
  total_stats[:damage_taken] += fighter.statblock.damage_taken
end

def report_stats(name, stats, days)
  puts "Build: #{name.ljust(15)}"
  avgs = calculate_report_averages(stats, days)
  puts "  Avg Damage Dealt/Day: #{avgs[:dealt]}"
  puts "  Avg Damage Taken/Day: #{avgs[:taken]}"
  puts "  Win Rate: #{avgs[:win_rate]}%"
  puts ''
end

def calculate_report_averages(stats, days)
  {
    dealt: (stats[:damage_dealt].to_f / days).round(2),
    taken: (stats[:damage_taken].to_f / days).round(2),
    win_rate: (stats[:wins].to_f / (days * 3) * 100).round(1)
  }
end

LEVEL = 5
DAYS = 500

puts "=== Science: Fighter Build Comparison (Level #{LEVEL}) ==="
puts 'Isolated Variables: Archetype vs Build Synergies (2024 Rules)'
puts ''

run_experiment(->(l) { create_nick_vex_champion(l) }, LEVEL, DAYS)
run_experiment(->(l) { create_nick_vex_battlemaster(l) }, LEVEL, DAYS)
run_experiment(->(l) { create_heavy_champion(l) }, LEVEL, DAYS)
run_experiment(->(l) { create_heavy_battlemaster(l) }, LEVEL, DAYS)
