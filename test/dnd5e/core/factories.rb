module Dnd5e
  module Core
    module Factories
      class StatblockFactory
        def self.create(name: "Statblock", strength: 10, dexterity: 10, constitution: 10, intelligence: 10, wisdom: 10, charisma: 10, hit_die: "d8", level: 1)
          Statblock.new(name: name, strength: strength, dexterity: dexterity, constitution: constitution, intelligence: intelligence, wisdom: wisdom, charisma: charisma, hit_die: hit_die, level: level)
        end

        def self.create_hero_statblock
          create(name: "Hero Statblock", strength: 16, dexterity: 10, constitution: 15, hit_die: "d10", level: 3)
        end

        def self.create_goblin_statblock
          create(name: "Goblin Statblock", strength: 8, dexterity: 14, constitution: 10, hit_die: "d6", level: 1)
        end
      end

      class AttackFactory
        def self.create(name: "Attack", damage_dice:, extra_attack_bonus: 0, extra_damage_bonus: 0, range: :melee, count: 1, relevant_stat: :strength)
          Attack.new(name: name, damage_dice: damage_dice, extra_attack_bonus: extra_attack_bonus, extra_damage_bonus: extra_damage_bonus, range: range, count: count, relevant_stat: relevant_stat)
        end

        def self.create_sword_attack
          create(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength)
        end

        def self.create_bite_attack
          create(name: "Bite", damage_dice: Dice.new(1, 6), relevant_stat: :dexterity)
        end
      end

      class CharacterFactory
        def self.create(name: "Character", statblock: StatblockFactory.create_hero_statblock, attacks: [], team: nil)
          Character.new(name: name, statblock: statblock, attacks: attacks, team: team)
        end

        def self.create_hero
          create(name: "Hero", statblock: StatblockFactory.create_hero_statblock, attacks: [AttackFactory.create_sword_attack])
        end
      end

      class MonsterFactory
        def self.create(name: "Monster", statblock: StatblockFactory.create_goblin_statblock, attacks: [], team: nil)
          Monster.new(name: name, statblock: statblock, attacks: attacks, team: team)
        end

        def self.create_goblin
          create(name: "Goblin", statblock: StatblockFactory.create_goblin_statblock, attacks: [AttackFactory.create_bite_attack])
        end
      end
    end
  end
end
