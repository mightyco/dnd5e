# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/builders/monster_builder'
require_relative '../../../lib/dnd5e/core/team'
require_relative '../../../lib/dnd5e/core/team_combat'

module Dnd5e
  module Integration
    class TestAttackRedirection < Minitest::Test
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def setup
        @hero_builder = Builders::CharacterBuilder.new(name: 'Big Damn Hero')
        @monster_builder = Builders::MonsterBuilder.new(name: 'Bugbear')
      end

      def test_fighter_redirects_extra_attack_on_death
        hero = @hero_builder.as_fighter(level: 5, abilities: { strength: 20 }).build
        # B1 has low HP, B2 has high HP
        b1 = @monster_builder.with_statblock(Core::Statblock.new(name: 'B1', hit_points: 5, armor_class: 1)).build
        b2 = @monster_builder.with_statblock(Core::Statblock.new(name: 'B2', hit_points: 50, armor_class: 1)).build

        combat = Core::TeamCombat.new(teams: [
                                        Core::Team.new(name: 'Heroes', members: [hero]),
                                        Core::Team.new(name: 'Monsters', members: [b1, b2])
                                      ], distance: 5)

        # Mock rolls:
        # Attack 1 (B1): 20 (hit), 10 dmg -> B1 DEAD
        # Attack 2 (B2): 20 (hit), 10 dmg -> B2 HIT
        hero.attacks.first.dice_roller.instance_variable_set(:@rolls, [20, 10, 20, 10])
        hero.attacks.first.dice_roller.instance_variable_set(:@index, 0)

        # Force hero to go first
        def combat.prepare_combat
          @turn_manager.instance_variable_set(:@turn_order, combatants.sort_by do |c|
            c.name == 'Big Damn Hero' ? -1 : 1
          end)
          @round_counter = 1
        end

        combat.run_combat

        refute_predicate b1.statblock, :alive?, 'B1 should be dead'
        assert_predicate b2.statblock.damage_taken, :positive?, 'B2 should have taken damage from redirected attack'
      end

      def test_battlemaster_redirects_action_surge_attacks
        hero = @hero_builder.as_fighter(level: 5, abilities: { strength: 20 })
                            .with_subclass('battlemaster', level: 5)
                            .build
        hero.statblock.resources.instance_variable_get(:@resources)[:action_surge] = 1

        # B1 dies on 3rd attack (first attack of Action Surge)
        b1 = @monster_builder.with_statblock(Core::Statblock.new(name: 'B1', hit_points: 25, armor_class: 1)).build
        b2 = @monster_builder.with_statblock(Core::Statblock.new(name: 'B2', hit_points: 50, armor_class: 1)).build

        combat = Core::TeamCombat.new(teams: [
                                        Core::Team.new(name: 'Heroes', members: [hero]),
                                        Core::Team.new(name: 'Monsters', members: [b1, b2])
                                      ], distance: 5)

        # Mock rolls:
        # Action 1: Atk 1 (B1, 10), Atk 2 (B1, 10) -> B1 HP 5
        # Action Surge
        # Action 2: Atk 3 (B1, 10) -> B1 DEAD, Atk 4 (B2, 10) -> B2 HIT
        hero.attacks.first.dice_roller.instance_variable_set(:@rolls, [20, 10, 20, 10, 20, 10, 20, 10])
        hero.attacks.first.dice_roller.instance_variable_set(:@index, 0)

        def combat.prepare_combat
          @turn_manager.instance_variable_set(:@turn_order, combatants.sort_by do |c|
            c.name == 'Big Damn Hero' ? -1 : 1
          end)
          @round_counter = 1
        end

        combat.run_combat

        refute_predicate b1.statblock, :alive?, 'B1 should be dead'
        assert_predicate b2.statblock.damage_taken, :positive?,
                         'B2 should have taken damage from Action Surge redirection'
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
