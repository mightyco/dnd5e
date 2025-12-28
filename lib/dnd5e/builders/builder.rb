# frozen_string_literal: true

module Dnd5e
  # Core domain models for D&D 5e.
  module Core
  end

  # Namespace for builder classes.
  #
  # This module provides a set of builder classes that facilitate the creation
  # of complex game objects, such as characters, monsters, and teams. These
  # builders use a fluent interface, allowing for a more readable and
  # maintainable way to construct objects step-by-step.
  #
  # Each builder class follows a similar pattern:
  #
  # 1.  **Initialization:** The builder is initialized with required parameters (e.g., name).
  # 2.  **Configuration:** `with_` methods are used to configure the object being built
  #     (e.g., `with_statblock`, `with_attack`, `with_member`).
  # 3.  **Building:** The `build` method creates and returns the final object.
  #
  # @example Creating a character
  #   statblock = Statblock.new(strength: 10, dexterity: 12)
  #   attack = Attack.new(name: "Sword", damage: "1d8")
  #   character = Dnd5e::Builders::CharacterBuilder.new(name: "Aragorn")
  #                                                .with_statblock(statblock)
  #                                                .with_attack(attack)
  #                                                .build
  #
  # @example Creating a monster
  #   statblock = Statblock.new(strength: 18, dexterity: 14)
  #   attack = Attack.new(name: "Claw", damage: "2d6")
  #   monster = Dnd5e::Builders::MonsterBuilder.new(name: "Dragon")
  #                                              .with_statblock(statblock)
  #                                              .with_attack(attack)
  #                                              .build
  #
  # @example Creating a team
  #   team = Dnd5e::Builders::TeamBuilder.new(name: "Fellowship")
  #                                       .with_member(character)
  #                                       .with_member(monster)
  #                                       .build
  module Builders
  end
end
