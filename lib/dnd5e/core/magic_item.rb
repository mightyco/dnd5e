# frozen_string_literal: true

module Dnd5e
  module Core
    # Represents a magic item.
    class MagicItem
      attr_reader :name, :rarity, :type, :attunement, :description

      def initialize(name:, rarity:, type:, attunement:, description:)
        @name = name
        @rarity = rarity
        @type = type
        @attunement = attunement
        @description = description
      end
    end
  end
end
