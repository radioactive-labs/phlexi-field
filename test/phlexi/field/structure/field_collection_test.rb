# frozen_string_literal: true

require "test_helper"

module Phlexi
  module Field
    module Structure
      class FieldCollectionTest < Minitest::Test
        include ComponentTestHelper

        class MockField
          attr_reader :key, :parent

          def initialize(key, parent:, **options)
            @key = key
            @parent = parent
            @options = options
          end
        end

        def setup
          @parent = MockField.new(:parent, parent: nil)
          @field = MockField.new(:field, parent: @parent)
          @collection = ["item1", "item2", "item3"]
        end

        def test_initialize
          field_collection = FieldCollection.new(field: @field, collection: @collection)
          
          assert_equal @field, field_collection.instance_variable_get(:@field)
          assert_equal @collection, field_collection.instance_variable_get(:@collection)
        end

        def test_initialize_with_block
          builders = []
          
          field_collection = FieldCollection.new(field: @field, collection: @collection) do |builder|
            builders << builder
          end
          
          assert_equal 3, builders.size
          assert_instance_of FieldCollection::Builder, builders.first
        end

        def test_each
          builders = []
          
          field_collection = FieldCollection.new(field: @field, collection: @collection)
          field_collection.each do |builder|
            builders << builder
          end
          
          assert_equal 3, builders.size
          assert_instance_of FieldCollection::Builder, builders.first
          assert_equal "item1", builders.first.key
          assert_equal 0, builders.first.index
          assert_equal "item2", builders[1].key
          assert_equal 1, builders[1].index
          assert_equal "item3", builders[2].key
          assert_equal 2, builders[2].index
        end

        def test_builder_field_method
          field_collection = FieldCollection.new(field: @field, collection: @collection)
          builder = nil
          
          field_collection.each do |b|
            builder = b
            break
          end
          
          created_field = builder.field(foo: "bar")
          
          assert_instance_of MockField, created_field
          assert_equal "item1", created_field.key
          assert_equal @field, created_field.parent
        end

        def test_builder_field_with_block
          field_collection = FieldCollection.new(field: @field, collection: @collection)
          builder = nil
          
          field_collection.each do |b|
            builder = b
            break
          end
          
          block_called = false
          created_field = builder.field do |f|
            block_called = true
            assert_equal "item1", f.key
          end
          
          assert block_called, "Block should be called when creating a field"
        end
      end
    end
  end
end 