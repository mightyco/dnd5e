require_relative "../lib/dnd5e/core/team_combat"
require_relative "../lib/dnd5e/core/character"
require_relative "../lib/dnd5e/core/statblock"
require_relative "../lib/dnd5e/core/attack"
require_relative "../lib/dnd5e/core/dice"
require_relative "../lib/dnd5e/core/team"
require 'logger'

module Dnd5e
  module Examples
    # A custom observer that listens for specific combat events
    class CriticalHitAnnouncer
      def update(event, data)
        # We only care about attacks that might be critical hits
        # (For simplicity, let's assume a roll of 20 is a crit, though we don't have raw roll data here easily accessible
        # without digging into the dice roller results, so we'll just announce every attack for this example)
        if event == :attack
          attacker = data[:attacker]
          defender = data[:defender]
          puts ">> EVENT: #{attacker.name} is swinging at #{defender.name}!"
        elsif event == :combat_end
          winner = data[:winner]
          puts ">> EVENT: The dust settles! Winner: #{winner ? winner.name : 'Nobody'}"
        end
      end
    end

    class CustomObserverExample
      def self.run
        # Setup
        sword = Core::Attack.new(name: "Sword", damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength)
        
        hero = Core::Character.new(
          name: "Hero", 
          statblock: Core::Statblock.new(name: "Hero Stats", strength: 16, hit_die: "d10", level: 1), 
          attacks: [sword]
        )
        
        villain = Core::Character.new(
          name: "Villain", 
          statblock: Core::Statblock.new(name: "Villain Stats", strength: 16, hit_die: "d10", level: 1), 
          attacks: [sword]
        )

        team1 = Core::Team.new(name: "Blue Team", members: [hero])
        team2 = Core::Team.new(name: "Red Team", members: [villain])

        # Initialize Combat
        combat = Core::TeamCombat.new(teams: [team1, team2])

        # Attach our custom observer
        announcer = CriticalHitAnnouncer.new
        combat.add_observer(announcer)

        puts "Starting combat with custom observer..."
        combat.run_combat
      end
    end
  end
end

Dnd5e::Examples::CustomObserverExample.run
