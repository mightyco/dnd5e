# frozen_string_literal: true

require_relative 'lib/dnd5e/builders/character_builder'
require_relative 'lib/dnd5e/builders/monster_builder'
require_relative 'lib/dnd5e/core/combat'
require_relative 'lib/dnd5e/core/team'

builder = Dnd5e::Builders::CharacterBuilder.new(name: 'Lee')
monk = builder.as_monk(level: 2, abilities: { dexterity: 16 }).build
enemy_statblock = Dnd5e::Core::Statblock.new(name: 'Enemy', hit_points: 30, armor_class: 10)
enemy = Dnd5e::Builders::MonsterBuilder.new(name: 'Skeleton')
                                       .with_statblock(enemy_statblock).build
player_team = Dnd5e::Core::Team.new(name: 'Players', members: [monk])
monster_team = Dnd5e::Core::Team.new(name: 'Monsters', members: [enemy])
monk.team = player_team
enemy.team = monster_team
combat = Dnd5e::Core::Combat.new(combatants: [monk, enemy])

puts "Monk speed: #{monk.statblock.speed}"
puts "Monk Focus: #{monk.statblock.resources[:focus_points]}"
monk.start_turn
monk.strategy.execute_turn(monk, combat)
puts "Bonus action used? #{!monk.turn_context.bonus_action_available?}"
