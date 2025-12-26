require_relative "../lib/dnd5e/core/team_combat"
require_relative "../lib/dnd5e/builders/team_builder"
require_relative "../lib/dnd5e/builders/character_builder"
require_relative "../lib/dnd5e/core/attack"
require_relative "../lib/dnd5e/core/dice"
require_relative "../lib/dnd5e/core/combat_logger"
require_relative "../lib/dnd5e/core/team" # Added missing require
require 'logger'

# Setup Fighter
fighter = Dnd5e::Builders::CharacterBuilder.new(name: "Fighter")
                                           .as_fighter(level: 1, abilities: { strength: 16, constitution: 14 })
                                           .build

# Setup Wizard
wizard = Dnd5e::Builders::CharacterBuilder.new(name: "Wizard")
                                          .as_wizard(level: 1, abilities: { intelligence: 16, dexterity: 14, constitution: 14 })
                                          .build

# Add Fireball to Wizard (Level 5 feature, but useful for testing save interaction)
fireball = Dnd5e::Core::Attack.new(
  name: "Fireball",
  damage_dice: Dnd5e::Core::Dice.new(8, 6),
  type: :save,
  save_ability: :dexterity,
  dc_stat: :intelligence,
  half_damage_on_save: true
)
wizard.attacks << fireball

# Teams
team_fighter = Dnd5e::Core::Team.new(name: "Fighters", members: [fighter])
team_wizard = Dnd5e::Core::Team.new(name: "Wizards", members: [wizard])

# Combat
logger = Logger.new($stdout)
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{msg}\n"
end
combat_logger = Dnd5e::Core::CombatLogger.new(logger)

combat = Dnd5e::Core::TeamCombat.new(teams: [team_fighter, team_wizard])
combat.add_observer(combat_logger)

puts "Starting Fighter vs Wizard Duel..."
combat.run_combat
