# frozen_string_literal: true

require "test_helper"

module Phlexi
  module Field
    module Components
      class BaseTest < Minitest::Test
        include ComponentTestHelper

        DomStruct = Struct.new(:id)
        FieldStruct = Struct.new(:dom, :name, :key)

        def setup
          # Create a basic field for testing
          @field = FieldStruct.new(
            DomStruct.new("test_field"),
            "test_field",
            "test_field"
          )
        end

        def test_initializes_with_field_and_attributes
          component = Base.new(@field, foo: "bar")

          assert_equal @field, component.field
          assert_equal({foo: "bar", id: "test_field_base", class: "base"}, component.attributes)
        end

        def test_builds_id_attribute_if_not_provided
          component = Base.new(@field)

          assert_equal "test_field_base", component.attributes[:id]
        end

        def test_uses_provided_id_attribute
          component = Base.new(@field, id: "custom_id")

          assert_equal "custom_id", component.attributes[:id]
        end

        def test_builds_component_class
          component = Base.new(@field)

          assert_equal "base", component.attributes[:class]
        end

        def test_appends_to_existing_class
          component = Base.new(@field, class: "custom")

          assert_equal "base custom", component.attributes[:class]
        end

        def test_skips_class_attribute_when_false
          component = Base.new(@field, class: false)

          assert_equal false, component.attributes[:class]
        end
      end
    end
  end
end
