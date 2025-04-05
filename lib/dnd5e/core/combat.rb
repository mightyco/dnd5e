require_relative "dice"
require 'logger'

module Dnd5e
  module Core
    class Combat
      attr_reader :combatant1, :combatant2, :turn_order, :logger

      def initialize(combatant1:, combatant2:, logger: Logger.new($stdout))
        @combatant1 = combatant1
        @combatant2 = combatant2
        @turn_order = []
        @logger = logger
        logger.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end
      end

      def roll_initiative
        [@combatant1, @combatant2].each do |combatant|
          initiative_roll = Dice.new(1, 20, modifier: combatant.statblock.ability_modifier(:dexterity)).roll.first
          combatant.instance_variable_set(:@initiative, initiative_roll)
          @turn_order << combatant
        end
      end

      def sort_by_initiative
        @turn_order.sort_by! { |combatant| [-combatant.instance_variable_get(:@initiative), -combatant.statblock.dexterity] }
      end

      def attack(attacker, defender)
        attack_roll = Dice.new(1, 20, modifier: attacker.statblock.ability_modifier(attacker.attacks.first.relevant_stat)).roll.first
        if attack_roll >= defender.statblock.armor_class
          damage = attacker.attacks.first.damage_dice.roll.sum
          defender.statblock.take_damage(damage)
          logger.info "#{attacker.name} hits #{defender.name} for #{damage} damage!"
          logger.info "#{defender.name} is defeated!" unless defender.statblock.is_alive?
        else
          logger.info "#{attacker.name} misses #{defender.name}!"
        end
      end

      def take_turn(attacker)
        defender = attacker == @combatant1 ? @combatant2 : @combatant1
        return if defender.nil? || !defender.statblock.is_alive?
        attack(attacker, defender)
      end

      def is_over?
        !@combatant1.statblock.is_alive? || !@combatant2.statblock.is_alive?
      end

      def winner
        return @combatant1 unless @combatant2.statblock.is_alive?
        return @combatant2 unless @combatant1.statblock.is_alive?
        nil
      end

      def start
        roll_initiative
        sort_by_initiative
        until is_over?
          @turn_order.each do |combatant|
            take_turn(combatant) if combatant.statblock.is_alive?
          end
        end
      end
    end
  end
end
