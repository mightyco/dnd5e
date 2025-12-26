require_relative "../lib/dnd5e/experiments/experiment"
require_relative "../lib/dnd5e/builders/character_builder"
require_relative "../lib/dnd5e/core/team"
require_relative "../lib/dnd5e/core/attack"
require_relative "../lib/dnd5e/core/dice"
require_relative "../lib/dnd5e/core/armor"

# Experiment: Strength (Heavy Armor) vs Dexterity (Light Armor)
# Hypothesis: Strength should have a slight advantage at Level 1 due to AC 16 vs AC 15.
# However, Dex Initiative might still tip the scales.

Dnd5e::Experiments::Experiment.new(name: "Equipment Impact: Plate vs Leather")
  .independent_variable(:level, values: 1..10)
  .simulations_per_step(500)
  .control_group do |params|
    # Strength Build
    # AC 16 (Chain Mail)
    # Weapon: Longsword (1d8 + 3)
    level = params[:level]
    
    chain_mail = Dnd5e::Core::Armor.new(
      name: "Chain Mail", 
      base_ac: 16, 
      type: :heavy, 
      max_dex_bonus: 0, 
      stealth_disadvantage: true
    )
    
    char = Dnd5e::Builders::CharacterBuilder.new(name: "Str Knight")
      .as_fighter(level: level, abilities: { strength: 16, dexterity: 10, constitution: 14 })
      .build
      
    char.statblock.equipped_armor = chain_mail
    char
    
    Dnd5e::Core::Team.new(name: "Str Team", members: [char])
  end
  .test_group do |params|
    # Dexterity Build
    # AC 12 + 3 (Studded Leather) = 15
    # Weapon: Rapier (1d8 + 3)
    level = params[:level]
    
    studded_leather = Dnd5e::Core::Armor.new(
      name: "Studded Leather", 
      base_ac: 12, 
      type: :light, 
      max_dex_bonus: nil, # Unlimited
      stealth_disadvantage: false
    )
    
    char = Dnd5e::Builders::CharacterBuilder.new(name: "Dex Duelist")
      .as_fighter(level: level, abilities: { strength: 10, dexterity: 16, constitution: 14 })
      .build
      
    # Swap weapon to Rapier
    rapier = Dnd5e::Core::Attack.new(name: "Rapier", damage_dice: Dnd5e::Core::Dice.new(1, 8), relevant_stat: :dexterity)
    char.attacks = [rapier]
    
    char.statblock.equipped_armor = studded_leather
    char
    
    Dnd5e::Core::Team.new(name: "Dex Team", members: [char])
  end
  .run
