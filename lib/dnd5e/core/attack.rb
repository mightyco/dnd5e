require_relative "dice"
require_relative "dice_roller"
require 'logger'

module Dnd5e
  module Core
    class Attack
      attr_reader :name, :damage_dice, :relevant_stat, :logger, :dice_roller

      def initialize(name:, damage_dice:, relevant_stat: :strength, logger: Logger.new($stdout), dice_roller: DiceRoller.new)
        @name = name
        @damage_dice = damage_dice
        @relevant_stat = relevant_stat
        @logger = logger
        @dice_roller = dice_roller
        logger.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end
      end

      def attack(attacker, defender)
        attack_roll = @dice_roller.roll_with_dice(Dice.new(1, 20, modifier: attacker.statblock.ability_modifier(@relevant_stat)))
        if attack_roll >= defender.statblock.armor_class
          damage = @dice_roller.roll_with_dice(@damage_dice)
          defender.statblock.take_damage(damage)
          @logger.info "#{attacker.name} hits #{defender.name} for #{damage} damage!"
          @logger.info "#{defender.name} is defeated!" unless defender.statblock.is_alive?
          true
        else
          @logger.info "#{attacker.name} misses #{defender.name}!"
          false
        end
      end
    end
  end
end
