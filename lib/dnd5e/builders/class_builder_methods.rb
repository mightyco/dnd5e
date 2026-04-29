# frozen_string_literal: true

require_relative 'martial_class_methods'
require_relative 'caster_class_methods'
require_relative 'class_builder_helpers'

module Dnd5e
  module Builders
    # Separate module for individual class methods to keep CharacterBuilder small.
    module ClassBuilderMethods
      include MartialClassMethods
      include CasterClassMethods
      include ClassBuilderHelpers
    end
  end
end
