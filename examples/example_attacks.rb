# Example of creating a character with attacks
longsword_attack = Dnd5e::Core::Attack.new(name: "Longsword Slash", damage_dice: Dnd5e::Core::Dice.new(1, 8), range: :melee)
greatsword_attack = Dnd5e::Core::Attack.new(name: "Greatsword Slash", damage_dice: Dnd5e::Core::Dice.new(2, 6), range: :melee)
character_statblock = Dnd5e::Core::Statblock.new(name: "Hero", strength: 16, level: 3)
hero = Dnd5e::Core::Character.new(name: "Aragorn", statblock: character_statblock, attacks: [longsword_attack, greatsword_attack])

# Example of creating a monster with attacks
goblin_statblock = Dnd5e::Core::Statblock.new(name: "Goblin Stats", strength: 8, dexterity: 14, constitution: 10, hit_die: "d6", level: 1)
scimitar_attack = Dnd5e::Core::Attack.new(name: "Scimitar Slash", damage_dice: Dnd5e::Core::Dice.new(1, 6), range: :melee)
goblin = Dnd5e::Core::Monster.new(name: "Goblin", statblock: goblin_statblock, attacks: [scimitar_attack])
