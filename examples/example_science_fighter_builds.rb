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
# Variables isolated: Archetype vs Optimized Stats vs Maneuver Usage

# --- BUILD GENERATORS ---

def create_dex_base(name, level)
  Dnd5e::Builders::CharacterBuilder.new(name: name)
                                   .as_fighter(level: level, abilities: { strength: 10, dexterity: 16,
                                                                          constitution: 14 },
                                               armor_type: :light)
end

def create_str_base(name, level)
  Dnd5e::Builders::CharacterBuilder.new(name: name)
                                   .as_fighter(level: level, abilities: { strength: 16, dexterity: 10,
                                                                          constitution: 14 },
                                               armor_type: :heavy)
end

def setup_dual_wield(builder, level)
  builder.with_feature(Dnd5e::Core::Features::TwoWeaponFighting.new)
  builder.with_feature(Dnd5e::Core::Features::DualWielder.new) if level >= 4

  vex = Dnd5e::Core::Attack.new(name: 'Vex Dagger', damage_dice: Dnd5e::Core::Dice.new(1, 4),
                                relevant_stat: :dexterity, mastery: :vex, properties: %i[light finesse])
  nick = Dnd5e::Core::Attack.new(name: 'Nick Dagger', damage_dice: Dnd5e::Core::Dice.new(1, 4),
                                 relevant_stat: :dexterity, mastery: :nick, properties: %i[light finesse])
  builder.with_attack(vex).with_attack(nick)
end

def setup_heavy(builder, mastery)
  builder.with_feature(Dnd5e::Core::Features::GreatWeaponMaster.new)
  weapon = Dnd5e::Core::Attack.new(name: 'Heavy Weapon', damage_dice: Dnd5e::Core::Dice.new(2, 6),
                                   relevant_stat: :strength, mastery: mastery, properties: %i[heavy two_handed])
  builder.with_attack(weapon)
end

# --- SPECIFIC BUILDS ---

def create_nick_vex_champ(level)
  b = create_dex_base('NickVexChamp', level).with_feature(Dnd5e::Core::Features::ImprovedCritical.new)
  setup_dual_wield(b, level).build
end

def create_nick_vex_bm(level)
  strat = Dnd5e::Core::Strategies::BattleMasterStrategy.new(use_precision_attack: true, use_damage_maneuver: true)
  b = create_dex_base('NickVexBM', level).with_feature(Dnd5e::Core::Features::BattleMaster.new(level: level))
  setup_dual_wield(b, level).build.tap { |f| f.strategy = strat }
end

def create_heavy_champ(level, mastery = :graze)
  name = mastery == :vex ? 'VexHeavyChamp' : 'HeavyChamp'
  b = create_str_base(name, level).with_feature(Dnd5e::Core::Features::ImprovedCritical.new)
  setup_heavy(b, mastery).build
end

def create_heavy_bm(level, use_maneuvers: true)
  name = use_maneuvers ? 'HeavyBM' : 'HeavyBM-Base'
  strat = Dnd5e::Core::Strategies::BattleMasterStrategy.new(use_precision_attack: use_maneuvers,
                                                            use_damage_maneuver: use_maneuvers)
  b = create_str_base(name, level).with_feature(Dnd5e::Core::Features::BattleMaster.new(level: level))
  setup_heavy(b, :cleave).build.tap { |f| f.strategy = strat }
end

# --- SIMULATION ENGINE ---

def create_monster_team(level)
  case level
  when 1..2 then 3.times.map { |i| Dnd5e::Builders::MonsterBuilder.new(name: "Goblin #{i}").as_goblin.build }
  when 3..4 then [Dnd5e::Builders::MonsterBuilder.new(name: 'Bugbear').as_bugbear.build]
  else 2.times.map { |i| Dnd5e::Builders::MonsterBuilder.new(name: "Bugbear #{i}").as_bugbear.build }
  end.then { |m| Dnd5e::Core::Team.new(name: 'Monsters', members: m) }
end

def run_experiment(fighter_gen, level, days)
  stats = { damage_dealt: 0, damage_taken: 0, wins: 0, rounds: 0 }
  days.times { run_simulated_day(fighter_gen.call(level), level, stats) }
  report_stats(fighter_gen.call(level).name, stats, days)
end

def run_simulated_day(fighter, level, total_stats)
  reset_fighter_for_day(fighter)
  3.times do |enc|
    fighter.statblock.resources.reset! if enc == 1
    monsters = create_monster_team(level)
    combat = Dnd5e::Core::TeamCombat.new(teams: [Dnd5e::Core::Team.new(name: 'Fighter', members: [fighter]), monsters],
                                         distance: 5)
    run_simulation_loop(combat, fighter, monsters, total_stats)
    total_stats[:wins] += 1 if fighter.statblock.alive?
  end
  record_daily_stats(fighter, total_stats)
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
    monsters.alive_members.each { |m| combat.take_turn(m) if fighter.statblock.alive? }
  end
end

def record_daily_stats(fighter, total_stats)
  total_stats[:damage_dealt] += fighter.statblock.damage_dealt
  total_stats[:damage_taken] += fighter.statblock.damage_taken
end

def report_stats(name, stats, days)
  avgs = calculate_report_averages(stats, days)
  puts "Build: #{name.ljust(15)}"
  puts "  Avg Damage Dealt/Day: #{avgs[:dealt]} | Avg Damage Taken/Day: #{avgs[:taken]} | Win Rate: #{avgs[:win_rate]}%"
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
puts 'Isolated Variables: Archetype vs Optimized Stats (2024 Rules)'
puts ''

run_experiment(->(l) { create_nick_vex_champ(l) }, LEVEL, DAYS)
run_experiment(->(l) { create_nick_vex_bm(l) }, LEVEL, DAYS)
run_experiment(->(l) { create_heavy_champ(l, :graze) }, LEVEL, DAYS)
run_experiment(->(l) { create_heavy_champ(l, :vex) }, LEVEL, DAYS)
run_experiment(->(l) { create_heavy_bm(l, use_maneuvers: false) }, LEVEL, DAYS)
run_experiment(->(l) { create_heavy_bm(l, use_maneuvers: true) }, LEVEL, DAYS)
