require_relative "../core/character"
require_relative "../core/statblock"
require_relative "../core/attack"
require_relative "../core/dice"
require_relative "../core/armor"

module Dnd5e
  module Builders
    # Builds a Character object with a fluent interface.
    #
    # @see Dnd5e::Builders
    class CharacterBuilder
      # Error raised when an invalid character is built.
      class InvalidCharacterError < StandardError; end

      # Initializes a new CharacterBuilder.
      #
      # @param name [String] The name of the character.
      def initialize(name:)
        @name = name
        @statblock = nil
        @attacks = []
      end

      # Sets the statblock for the character.
      #
      # @param statblock [Statblock] The statblock for the character.
      # @return [CharacterBuilder] The CharacterBuilder instance.
      def with_statblock(statblock)
        @statblock = statblock
        self
      end

      # Adds an attack to the character.
      #
      # @param attack [Attack] The attack to add.
      # @return [CharacterBuilder] The CharacterBuilder instance.
      def with_attack(attack)
        @attacks << attack
        self
      end

      # Builds the character as a Fighter.
      #
      # @param level [Integer] The level of the fighter.
      # @param abilities [Hash] Ability scores (e.g., { strength: 16, dexterity: 12 }).
      # @return [CharacterBuilder] The CharacterBuilder instance.
      def as_fighter(level: 1, abilities: {})
        abilities = { strength: 10, dexterity: 10, constitution: 10, intelligence: 10, wisdom: 10, charisma: 10 }.merge(abilities)
        
        # Heavy Armor: Chain Mail (AC 16)
        chain_mail = Core::Armor.new(name: "Chain Mail", base_ac: 16, type: :heavy, max_dex_bonus: 0, stealth_disadvantage: true)
        
        @statblock = Core::Statblock.new(
          name: @name,
          strength: abilities[:strength],
          dexterity: abilities[:dexterity],
          constitution: abilities[:constitution],
          intelligence: abilities[:intelligence],
          wisdom: abilities[:wisdom],
          charisma: abilities[:charisma],
          hit_die: "d10",
          level: level,
          saving_throw_proficiencies: [:strength, :constitution],
          equipped_armor: chain_mail
        )
        
        # Add basic equipment (Longsword) if not already added
        # This is a bit simplistic, usually builders are more granular.
        # But per requirements "Implement Fighter Level 1 features (Hit Die, Saves, Equipment)"
        
        unless @attacks.any? { |a| a.name == "Longsword" }
          longsword = Core::Attack.new(name: "Longsword", damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength)
          with_attack(longsword)
        end
        
        # Fighter features like Fighting Style could modify stats here.
        # For now, we stick to the basics.
        
        self
      end

      # Builds the character as a Wizard.
      #
      # @param level [Integer] The level of the wizard.
      # @param abilities [Hash] Ability scores (e.g., { intelligence: 16, dexterity: 12 }).
      # @return [CharacterBuilder] The CharacterBuilder instance.
      def as_wizard(level: 1, abilities: {})
        abilities = { strength: 10, dexterity: 10, constitution: 10, intelligence: 10, wisdom: 10, charisma: 10 }.merge(abilities)
        
        # No Armor (Robes)
        
        @statblock = Core::Statblock.new(
          name: @name,
          strength: abilities[:strength],
          dexterity: abilities[:dexterity],
          constitution: abilities[:constitution],
          intelligence: abilities[:intelligence],
          wisdom: abilities[:wisdom],
          charisma: abilities[:charisma],
          hit_die: "d6",
          level: level,
          saving_throw_proficiencies: [:intelligence, :wisdom]
        )
        
        # Add basic equipment (Staff)
        unless @attacks.any? { |a| a.name == "Quarterstaff" }
          staff = Core::Attack.new(name: "Quarterstaff", damage_dice: Core::Dice.new(1, 6), relevant_stat: :strength)
          with_attack(staff)
        end
        
        # Add Firebolt cantrip
        firebolt = Core::Attack.new(
          name: "Firebolt", 
          damage_dice: Core::Dice.new(1, 10), 
          relevant_stat: :intelligence, 
          type: :attack # Ranged Spell Attack
        )
        with_attack(firebolt)
        
        self
      end

      # Builds the character.
      #
      # @return [Character] The built character.
      # @raise [InvalidCharacterError] if the character is invalid.
      def build
        raise InvalidCharacterError, "Character must have a name" if @name.nil? || @name.empty?
        raise InvalidCharacterError, "Character must have a statblock" if @statblock.nil?

        Core::Character.new(name: @name, statblock: @statblock, attacks: @attacks)
      end
    end
  end
end
