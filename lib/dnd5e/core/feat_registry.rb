# frozen_string_literal: true

require_relative 'features/great_weapon_master'
require_relative 'features/sharpshooter'
require_relative 'features/dual_wielder'
require_relative 'features/tough'

module Dnd5e
  module Core
    # Registry for looking up and instantiating Feats.
    class FeatRegistry
      FEATS = {
        'great_weapon_master' => Features::GreatWeaponMaster,
        'sharpshooter' => Features::Sharpshooter,
        'dual_wielder' => Features::DualWielder,
        'tough' => Features::Tough
      }.freeze

      def self.create(feat_key)
        klass = FEATS[feat_key.to_s.downcase]
        raise ArgumentError, "Unknown feat: #{feat_key}" unless klass

        klass.new
      end

      def self.all_keys
        FEATS.keys
      end
    end
  end
end
