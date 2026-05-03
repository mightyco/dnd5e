# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/dnd5e/core/subclass_registry'

module Dnd5e
  module Core
    module Subclasses
      class TestMissingSubclasses < Minitest::Test
        def test_all_classes_have_three_subclasses
          all_classes = %i[fighter wizard rogue barbarian paladin monk ranger cleric bard druid sorcerer warlock]

          all_classes.each do |cls|
            subclasses = SubclassRegistry.subclasses_for(cls)

            assert_operator subclasses.length, :>=, 3,
                            "Class #{cls} should have at least 3 subclasses, found: #{subclasses.join(', ')}"
          end
        end
      end
    end
  end
end
