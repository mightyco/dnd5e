module Dnd5e
  module Core
    class Armor
      attr_reader :name, :base_ac, :type, :max_dex_bonus, :stealth_disadvantage

      TYPES = [:light, :medium, :heavy, :shield]

      # @param name [String] Name of the armor (e.g., "Chain Mail")
      # @param base_ac [Integer] Base AC value
      # @param type [Symbol] :light, :medium, :heavy, or :shield
      # @param max_dex_bonus [Integer, nil] Maximum Dex modifier to apply (nil for unlimited, 0 for none)
      # @param stealth_disadvantage [Boolean] Whether armor imposes stealth disadvantage
      def initialize(name:, base_ac:, type:, max_dex_bonus: nil, stealth_disadvantage: false)
        raise ArgumentError, "Invalid armor type" unless TYPES.include?(type)
        
        @name = name
        @base_ac = base_ac
        @type = type
        @max_dex_bonus = max_dex_bonus
        @stealth_disadvantage = stealth_disadvantage
      end

      def calculate_ac(dex_modifier)
        return @base_ac if @type == :shield # Shields handled separately usually, but for base logic

        bonus = dex_modifier
        if @max_dex_bonus
          bonus = [dex_modifier, @max_dex_bonus].min
        end
        # Heavy armor usually has max_dex_bonus = 0, but strictly it ignores neg mods too?
        # 5e Rules: Heavy Armor doesn't let you use Dex mod (pos or neg). 
        # So max_dex_bonus should be 0 for heavy.
        
        @base_ac + bonus
      end
    end
  end
end

