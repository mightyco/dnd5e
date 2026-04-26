# frozen_string_literal: true

require_relative 'class_logic/fighter_logic'
require_relative 'class_logic/rogue_logic'
require_relative 'class_logic/wizard_logic'
require_relative 'class_logic/barbarian_logic'
require_relative 'class_logic/paladin_logic'
require_relative 'class_logic/monk_logic'
require_relative 'class_logic/ranger_logic'
require_relative 'class_logic/cleric_logic'
require_relative 'class_logic/bard_logic'
require_relative 'class_logic/druid_logic'
require_relative 'class_logic/sorcerer_logic'
require_relative 'class_logic/warlock_logic'

module Dnd5e
  module Builders
    # Specific build logic for different classes.
    module ClassBuildLogic
      include ClassLogic::FighterLogic
      include ClassLogic::RogueLogic
      include ClassLogic::WizardLogic
      include ClassLogic::BarbarianLogic
      include ClassLogic::PaladinLogic
      include ClassLogic::MonkLogic
      include ClassLogic::RangerLogic
      include ClassLogic::ClericLogic
      include ClassLogic::BardLogic
      include ClassLogic::DruidLogic
      include ClassLogic::SorcererLogic
      include ClassLogic::WarlockLogic
    end
  end
end
