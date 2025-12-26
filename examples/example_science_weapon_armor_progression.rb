require_relative "../lib/dnd5e/experiments/experiment"
require_relative "../lib/dnd5e/builders/character_builder"
require_relative "../lib/dnd5e/core/team"
require_relative "../lib/dnd5e/core/attack"
require_relative "../lib/dnd5e/core/dice"
require_relative "../lib/dnd5e/core/armor"

# --- Shared Builders ---

def create_str_shield(level)
  armor_name = level >= 7 ? "Plate" : "Chain Mail"
  base_ac = level >= 7 ? 18 : 16
  armor = Dnd5e::Core::Armor.new(name: armor_name, base_ac: base_ac, type: :heavy, max_dex_bonus: 0, stealth_disadvantage: true)
  shield = Dnd5e::Core::Armor.new(name: "Shield", base_ac: 2, type: :shield)
  
  char = Dnd5e::Builders::CharacterBuilder.new(name: "Str Shield")
    .as_fighter(level: level, abilities: { strength: 16, dexterity: 10, constitution: 14 })
    .build
  char.statblock.equipped_armor = armor
  char.statblock.equipped_shield = shield
  char
end

def create_str_greatsword(level)
  armor_name = level >= 7 ? "Plate" : "Chain Mail"
  base_ac = level >= 7 ? 18 : 16
  armor = Dnd5e::Core::Armor.new(name: armor_name, base_ac: base_ac, type: :heavy, max_dex_bonus: 0, stealth_disadvantage: true)
  
  char = Dnd5e::Builders::CharacterBuilder.new(name: "Str GW")
    .as_fighter(level: level, abilities: { strength: 16, dexterity: 10, constitution: 14 })
    .build
  char.statblock.equipped_armor = armor
  
  greatsword = Dnd5e::Core::Attack.new(name: "Greatsword", damage_dice: Dnd5e::Core::Dice.new(2, 6), relevant_stat: :strength)
  char.attacks = [greatsword]
  char
end

def create_dex_shield(level)
  if level >= 5
    armor = Dnd5e::Core::Armor.new(name: "Breastplate", base_ac: 14, type: :medium, max_dex_bonus: 2)
  else
    armor = Dnd5e::Core::Armor.new(name: "Studded Leather", base_ac: 12, type: :light, max_dex_bonus: nil)
  end
  shield = Dnd5e::Core::Armor.new(name: "Shield", base_ac: 2, type: :shield)
  
  char = Dnd5e::Builders::CharacterBuilder.new(name: "Dex Shield")
    .as_fighter(level: level, abilities: { strength: 10, dexterity: 16, constitution: 14 })
    .build
  char.statblock.equipped_armor = armor
  char.statblock.equipped_shield = shield
  
  rapier = Dnd5e::Core::Attack.new(name: "Rapier", damage_dice: Dnd5e::Core::Dice.new(1, 8), relevant_stat: :dexterity)
  char.attacks = [rapier]
  char
end

def create_dex_skirmisher(level)
  if level >= 5
    armor = Dnd5e::Core::Armor.new(name: "Breastplate", base_ac: 14, type: :medium, max_dex_bonus: 2)
  else
    armor = Dnd5e::Core::Armor.new(name: "Studded Leather", base_ac: 12, type: :light, max_dex_bonus: nil)
  end
  
  char = Dnd5e::Builders::CharacterBuilder.new(name: "Dex Skirm")
    .as_fighter(level: level, abilities: { strength: 10, dexterity: 16, constitution: 14 })
    .build
  char.statblock.equipped_armor = armor
  
  rapier = Dnd5e::Core::Attack.new(name: "Rapier", damage_dice: Dnd5e::Core::Dice.new(1, 8), relevant_stat: :dexterity)
  char.attacks = [rapier]
  char
end

# --- Experiment 1: Str Shield vs Dex Shield (Classic) ---
Dnd5e::Experiments::Experiment.new(name: "1. Str Shield vs Dex Shield")
  .independent_variable(:level, values: 1..10)
  .simulations_per_step(500)
  .control_group { |p| Dnd5e::Core::Team.new(name: "Str Shield", members: [create_str_shield(p[:level])]) }
  .test_group { |p| Dnd5e::Core::Team.new(name: "Dex Shield", members: [create_dex_shield(p[:level])]) }
  .run

puts "\n"

# --- Experiment 2: Str Shield vs Str Greatsword ---
Dnd5e::Experiments::Experiment.new(name: "2. Str Shield vs Str Greatsword")
  .independent_variable(:level, values: 1..10)
  .simulations_per_step(500)
  .control_group { |p| Dnd5e::Core::Team.new(name: "Str Shield", members: [create_str_shield(p[:level])]) }
  .test_group { |p| Dnd5e::Core::Team.new(name: "Str GW", members: [create_str_greatsword(p[:level])]) }
  .run

puts "\n"

# --- Experiment 3: Dex Shield vs Dex Skirmisher ---
Dnd5e::Experiments::Experiment.new(name: "3. Dex Shield vs Dex Skirmisher")
  .independent_variable(:level, values: 1..10)
  .simulations_per_step(500)
  .control_group { |p| Dnd5e::Core::Team.new(name: "Dex Shield", members: [create_dex_shield(p[:level])]) }
  .test_group { |p| Dnd5e::Core::Team.new(name: "Dex Skirm", members: [create_dex_skirmisher(p[:level])]) }
  .run

puts "\n"

# --- Experiment 4: Str Greatsword vs Dex Shield ---
Dnd5e::Experiments::Experiment.new(name: "4. Str Greatsword vs Dex Shield")
  .independent_variable(:level, values: 1..10)
  .simulations_per_step(500)
  .control_group { |p| Dnd5e::Core::Team.new(name: "Str GW", members: [create_str_greatsword(p[:level])]) }
  .test_group { |p| Dnd5e::Core::Team.new(name: "Dex Shield", members: [create_dex_shield(p[:level])]) }
  .run

puts "\n"

# --- Experiment 5: Str Greatsword vs Dex Skirmisher ---
Dnd5e::Experiments::Experiment.new(name: "5. Str Greatsword vs Dex Skirmisher")
  .independent_variable(:level, values: 1..10)
  .simulations_per_step(500)
  .control_group { |p| Dnd5e::Core::Team.new(name: "Str GW", members: [create_str_greatsword(p[:level])]) }
  .test_group { |p| Dnd5e::Core::Team.new(name: "Dex Skirm", members: [create_dex_skirmisher(p[:level])]) }
  .run
