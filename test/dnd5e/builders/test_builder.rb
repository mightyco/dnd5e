require_relative "../../test_helper"

module Dnd5e
  module Builders
    class TestBuilder < Minitest::Test
      def test_module_exists
        assert_kind_of Module, Dnd5e::Builders
      end

      def test_core_submodule_exists
        assert_kind_of Module, Dnd5e::Core
      end

      def test_module_has_no_code
        assert_empty Dnd5e::Builders.instance_methods
      end
    end
  end
end
