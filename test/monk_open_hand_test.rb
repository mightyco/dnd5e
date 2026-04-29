# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/combat'
require_relative '../lib/dnd5e/builders/monster_builder'

module Dnd5e
  class MonkOpenHandTest < Minitest::Test
    def setup
      initialize_combatants
      initialize_teams
      @combat = Core::Combat.new(combatants: [@monk, @enemy], distance: 5)
      @monk.start_turn
      sync_dice_rollers
    end

    def initialize_combatants
      @builder = Builders::CharacterBuilder.new(name: 'OpenHandLee')
      @monk = @builder.as_monk(level: 3, abilities: { dexterity: 16, wisdom: 14 })
                      .with_subclass(:openhand).build
      @enemy = Builders::MonsterBuilder.new(name: 'Target')
                                       .with_statblock(Core::Statblock.new(name: 'Target', hit_points: 50,
                                                                           armor_class: 10)).build
    end

    def initialize_teams
      @player_team = Core::Team.new(name: 'Players', members: [@monk])
      @monster_team = Core::Team.new(name: 'Monsters', members: [@enemy])
    end

    def sync_dice_rollers
      @monk.attacks.each do |attack|
        attack.instance_variable_set(:@dice_roller, @combat.dice_roller)
      end
    end

    def test_open_hand_technique_topples
      # Force Flurry of Blows
      # Attacks: 1 Action, 2 Flurry
      # Rolls needed:
      # 1. Action attack roll (1d20) -> 10 (Hit)
      # 2. Action damage (1d6) -> 4
      # 3. Flurry 1 attack (1d20) -> 10 (Hit)
      # 4. Flurry 1 damage (1d6) -> 4
      # 5. Flurry 1 Topple save (1d20) -> 1 (Fail)
      # 6. Flurry 2 attack (1d20) -> 10 (Hit, should have advantage but we roll one dice if not specified?)
      # Actually, if prone, it WILL call roll_with_advantage which consumes 2 rolls.
      # 6. Flurry 2 attack roll 1 -> 10
      # 7. Flurry 2 attack roll 2 -> 10
      # 8. Flurry 2 damage -> 4

      rolls = [10, 4, 10, 4, 1, 10, 10, 4]
      mock_roller = Core::MockDiceRoller.new(rolls)
      @combat.dice_roller = mock_roller
      @monk.attacks.each { |a| a.instance_variable_set(:@dice_roller, mock_roller) }
      @monk.statblock.resources.reset!

      # Execute turn - should use flurry and try to topple
      @monk.strategy.execute_turn(@monk, @combat)

      assert @enemy.condition?(:prone),
             "Enemy should be knocked prone by Open Hand Technique. Calls: #{mock_roller.calls.inspect}"
    end

    def test_open_hand_technique_addles_if_already_prone
      @enemy.add_condition(:prone)
      @monk.statblock.resources.reset!
      @monk.turn_context.reset!(30)

      # Rolls:
      # 1. Action attack (10)
      # 2. Action damage (4)
      # 3. Flurry 1 attack (10) - has advantage because prone
      # 4. Flurry 1 attack 2 (10)
      # 5. Flurry 1 damage (4)
      # No save for Addle
      # 6. Flurry 2 attack (10) - has advantage
      # 7. Flurry 2 attack 2 (10)
      # 8. Flurry 2 damage (4)
      rolls = [10, 4, 10, 10, 4, 10, 10, 4]
      mock_roller = Core::MockDiceRoller.new(rolls)

      @combat.dice_roller = mock_roller
      @monk.attacks.each { |a| a.instance_variable_set(:@dice_roller, mock_roller) }

      @monk.strategy.execute_turn(@monk, @combat)

      assert @enemy.condition?(:addled), 'Enemy should be addled if already prone'
    end

    def test_apply_technique_skips_addle_if_reactions_used
      @enemy.add_condition(:prone)
      @enemy.turn_context.use_reaction

      # We need to test apply_technique which is private, but on_attack_hit calls it.
      # Create an attack named 'Flurry of Blows'
      attack = Core::Attack.new(name: 'Flurry of Blows', damage_dice: Core::Dice.new(1, 6))
      context = { attacker: @monk, defender: @enemy, attack: attack, combat: @combat }

      feature = @monk.feature_manager.features.find { |f| f.is_a?(Core::Features::OpenHandTechnique) }
      feature.on_attack_hit(context)

      refute @enemy.condition?(:addled), 'Should not addle if reactions already used'
    end

    def test_topple_without_combat
      # Set DC very high to ensure topple if roll is 1
      # DC = 8 + Wis(2) + Prof(2) = 12.
      # 1 + Save(0) < 12.

      # We can't easily mock DiceRoller.new without more complex tools,
      # but we can at least execute the code path.
      attack = Core::Attack.new(name: 'Flurry of Blows', damage_dice: Core::Dice.new(1, 6))
      context = { attacker: @monk, defender: @enemy, attack: attack, combat: nil }

      feature = @monk.feature_manager.features.find { |f| f.is_a?(Core::Features::OpenHandTechnique) }
      # This will use a real DiceRoller and roll 1d20.
      # Statistically it will often succeed or fail, but we're testing the path.
      feature.on_attack_hit(context)
    end

    def test_on_attack_hit_skips_if_not_flurry
      attack = Core::Attack.new(name: 'Regular Strike', damage_dice: Core::Dice.new(1, 6))
      context = { attacker: @monk, defender: @enemy, attack: attack }

      feature = @monk.feature_manager.features.find { |f| f.is_a?(Core::Features::OpenHandTechnique) }
      feature.on_attack_hit(context)

      refute @enemy.condition?(:prone), 'Should not topple if not flurry'
      refute @enemy.condition?(:addled), 'Should not addle if not flurry'
    end
  end
end
