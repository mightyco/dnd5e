# frozen_string_literal: true

module Dnd5e
  module Core
    # Registry for looking up Weapon definitions.
    class WeaponRegistry
      WEAPONS = {
        'longsword' => { damage: '1d8', stat: :strength, mastery: :vex, properties: [:versatile] },
        'greatsword' => { damage: '2d6', stat: :strength, mastery: :graze, properties: %i[heavy two_handed] },
        'dagger' => { damage: '1d4', stat: :dexterity, mastery: :nick, properties: %i[light finesse thrown] },
        'shortsword' => { damage: '1d6', stat: :dexterity, mastery: :vex, properties: %i[finesse light] },
        'longbow' => { damage: '1d8', stat: :dexterity, mastery: :slow, properties: %i[ranged heavy two_handed] },
        'shortbow' => { damage: '1d6', stat: :dexterity, mastery: :vex, properties: %i[ranged two_handed] },
        'greataxe' => { damage: '1d12', stat: :strength, mastery: :cleave, properties: %i[heavy two_handed] },
        'warhammer' => { damage: '1d8', stat: :strength, mastery: :topple, properties: [:versatile] },
        'pike' => { damage: '1d10', stat: :strength, mastery: :push, properties: %i[heavy reach two_handed] },
        'rapier' => { damage: '1d8', stat: :dexterity, mastery: :vex, properties: [:finesse] },
        'battleaxe' => { damage: '1d8', stat: :strength, mastery: :topple, properties: [:versatile] }
      }.freeze

      def self.create(key)
        data = WEAPONS[key.to_s.downcase]
        return nil unless data

        Attack.new(
          name: key.capitalize,
          damage_dice: Dice.parse(data[:damage]),
          relevant_stat: data[:stat],
          mastery: data[:mastery],
          properties: data[:properties]
        )
      end

      def self.all_keys
        WEAPONS.keys
      end
    end

    # Registry for Armor and Shields.
    class ArmorRegistry
      ARMOR = {
        'padded' => { ac: 11, type: :light, max_dex: nil },
        'leather' => { ac: 11, type: :light, max_dex: nil },
        'studded_leather' => { ac: 12, type: :light, max_dex: nil },
        'hide' => { ac: 12, type: :medium, max_dex: 2 },
        'chain_shirt' => { ac: 13, type: :medium, max_dex: 2 },
        'breastplate' => { ac: 14, type: :medium, max_dex: 2 },
        'half_plate' => { ac: 15, type: :medium, max_dex: 2 },
        'ring_mail' => { ac: 14, type: :heavy, max_dex: 0 },
        'chain_mail' => { ac: 16, type: :heavy, max_dex: 0 },
        'splint' => { ac: 17, type: :heavy, max_dex: 0 },
        'plate' => { ac: 18, type: :heavy, max_dex: 0 },
        'shield' => { ac: 2, type: :shield, max_dex: nil }
      }.freeze

      def self.create(key)
        data = ARMOR[key.to_s.downcase]
        return nil unless data

        Armor.new(
          name: key.split('_').map(&:capitalize).join(' '),
          base_ac: data[:ac],
          type: data[:type],
          props: { max_dex_bonus: data[:max_dex] }
        )
      end

      def self.all_keys
        ARMOR.keys
      end
    end
  end
end
