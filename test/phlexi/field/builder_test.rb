# frozen_string_literal: true

require "test_helper"

module Phlexi
  module Field
    class BuilderTest < Minitest::Test
      include ComponentTestHelper

      class MockParent
        attr_reader :key
        def initialize(key = :parent)
          @key = key
        end
      end

      class MockObject
        attr_reader :name, :email, :active
        def initialize(name: nil, email: nil, active: false)
          @name = name
          @email = email
          @active = active
        end
      end

      def setup
        @parent = MockParent.new
        @object = MockObject.new(name: "Test User", email: "test@example.com", active: true)
      end

      def test_initialize_with_explicit_value
        builder = Builder.new(:name, parent: @parent, value: "Explicit Value")
        
        assert_equal "Explicit Value", builder.value
        assert_equal :name, builder.key
        assert_equal @parent, builder.parent
      end

      def test_initialize_with_object_value
        builder = Builder.new(:name, parent: @parent, object: @object)
        
        assert_equal "Test User", builder.value
        assert_equal :name, builder.key
      end

      def test_initialize_with_options
        options = { required: true, label: "Custom Label" }
        builder = Builder.new(:name, parent: @parent, object: @object, **options)
        
        assert_equal options, builder.options
      end

      def test_dom_instance
        builder = Builder.new(:name, parent: @parent)
        
        assert_instance_of Builder::DOM, builder.dom
        assert_equal builder, builder.dom.instance_variable_get(:@field)
      end

      def test_has_value_with_present_value
        builder = Builder.new(:name, parent: @parent, value: "Present")
        
        assert builder.has_value?
      end

      def test_has_value_with_false_value
        builder = Builder.new(:active, parent: @parent, value: false)
        
        assert builder.has_value?
      end

      def test_has_value_with_nil_value
        builder = Builder.new(:name, parent: @parent, value: nil)
        
        refute builder.has_value?
      end

      def test_has_value_with_empty_value
        builder = Builder.new(:name, parent: @parent, value: "")
        
        refute builder.has_value?
      end

      def test_repeated_creates_field_collection
        builder = Builder.new(:items, parent: @parent)
        collection = builder.repeated([1, 2, 3]) { |item| "Item #{item}" }
        
        assert_instance_of Builder::FieldCollection, collection
        assert_equal builder, collection.instance_variable_get(:@field)
        assert_equal [1, 2, 3], collection.instance_variable_get(:@collection)
      end
    end
  end
end 