# frozen_string_literal: true

require_relative '../lib/dnd5e/experiments/experiment'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/armor'

module Dnd5e
  module Examples
    # Runs experiments comparing different weapon and armor progressions.
    class WeaponArmorProgression
      def self.run
        new.run_experiments
      end

      def run_experiments
        [method(:experiment_one), method(:experiment_two),
         method(:experiment_three), method(:experiment_four),
         method(:experiment_five)].each do |exp|
          exp.call
          puts "\n"
        end
      end

      private

      def experiment_one
        run_experiment('1. Str Shield vs Dex Shield',
                       control_builder: ->(lvl) { create_str_shield(lvl) },
                       test_builder: ->(lvl) { create_dex_shield(lvl) })
      end

      def experiment_two
        run_experiment('2. Str Shield vs Str Greatsword',
                       control_builder: ->(lvl) { create_str_shield(lvl) },
                       test_builder: ->(lvl) { create_str_greatsword(lvl) })
      end

      def experiment_three
        run_experiment('3. Dex Shield vs Dex Skirmisher',
                       control_builder: ->(lvl) { create_dex_shield(lvl) },
                       test_builder: ->(lvl) { create_dex_skirmisher(lvl) })
      end

      def experiment_four
        run_experiment('4. Str Greatsword vs Dex Shield',
                       control_builder: ->(lvl) { create_str_greatsword(lvl) },
                       test_builder: ->(lvl) { create_dex_shield(lvl) })
      end

      def experiment_five
        run_experiment('5. Str Greatsword vs Dex Skirmisher',
                       control_builder: ->(lvl) { create_str_greatsword(lvl) },
                       test_builder: ->(lvl) { create_dex_skirmisher(lvl) })
      end

      def run_experiment(name, control_builder:, test_builder:)
        Experiments::Experiment.new(name: name)
                               .independent_variable(:level, values: 1..10)
                               .simulations_per_step(500)
                               .control_group { |p| Core::Team.new(name: 'Control', members: [control_builder.call(p[:level])]) }
                               .test_group { |p| Core::Team.new(name: 'Test', members: [test_builder.call(p[:level])]) }
                               .run
      end

      def create_str_shield(level)
        char = create_fighter('Str Shield', level, { strength: 16, dexterity: 10, constitution: 14 })
        char.statblock.equipped_armor = create_heavy_armor(level)
        char.statblock.equipped_shield = Core::Armor.new(name: 'Shield', base_ac: 2, type: :shield)
        char
      end

      def create_str_greatsword(level)
        char = create_fighter('Str GW', level, { strength: 16, dexterity: 10, constitution: 14 })
        char.statblock.equipped_armor = create_heavy_armor(level)
        char.attacks = [Core::Attack.new(name: 'Greatsword', damage_dice: Core::Dice.new(2, 6),
                                         relevant_stat: :strength)]
        char
      end

      def create_dex_shield(level)
        char = create_fighter('Dex Shield', level, { strength: 10, dexterity: 16, constitution: 14 })
        char.statblock.equipped_armor = create_light_or_medium_armor(level)
        char.statblock.equipped_shield = Core::Armor.new(name: 'Shield', base_ac: 2, type: :shield)
        equip_rapier(char)
        char
      end

      def create_dex_skirmisher(level)
        char = create_fighter('Dex Skirm', level, { strength: 10, dexterity: 16, constitution: 14 })
        char.statblock.equipped_armor = create_light_or_medium_armor(level)
        equip_rapier(char)
        char
      end

      def equip_rapier(char)
        char.attacks = [Core::Attack.new(name: 'Rapier', damage_dice: Core::Dice.new(1, 8), relevant_stat: :dexterity)]
      end

      def create_heavy_armor(level)
        name, ac = level >= 7 ? ['Plate', 18] : ['Chain Mail', 16]
        Core::Armor.new(name: name, base_ac: ac, type: :heavy, max_dex_bonus: 0, stealth_disadvantage: true)
      end

      def create_light_or_medium_armor(level)
        if level >= 5
          Core::Armor.new(name: 'Breastplate', base_ac: 14, type: :medium, max_dex_bonus: 2)
        else
          Core::Armor.new(name: 'Studded Leather', base_ac: 12, type: :light, max_dex_bonus: nil)
        end
      end

      def create_fighter(name, level, abilities)
        Builders::CharacterBuilder.new(name: name).as_fighter(level: level, abilities: abilities).build
      end
    end
  end
end

Dnd5e::Examples::WeaponArmorProgression.run
