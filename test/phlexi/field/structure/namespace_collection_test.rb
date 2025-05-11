# frozen_string_literal: true

require "test_helper"

module Phlexi
  module Field
    module Structure
      class NamespaceCollectionTest < Minitest::Test
        include ComponentTestHelper

        class MockParentNamespace < Namespace
          attr_reader :builder_klass

          def initialize(key, parent:, builder_klass: nil, **options)
            @builder_klass = builder_klass || Object
            super
          end
        end

        class MockObject
          attr_reader :id, :name
          def initialize(id, name)
            @id = id
            @name = name
          end
        end

        def setup
          @parent = MockParentNamespace.new(:parent, parent: nil, builder_klass: Object)
          @array_collection = [
            MockObject.new(1, "Object 1"),
            MockObject.new(2, "Object 2"),
            MockObject.new(3, "Object 3")
          ]
          @hash_collection = {
            first: MockObject.new(1, "First Object"),
            second: MockObject.new(2, "Second Object")
          }
        end

        def test_initialize_requires_block
          assert_raises(ArgumentError) do
            NamespaceCollection.new(:items, parent: @parent)
          end
        end

        def test_initialize_with_array_collection
          collection = NamespaceCollection.new(:items, parent: @parent, collection: @array_collection) do |item|
            # Block is required
          end
          
          assert_equal :items, collection.key
          assert_equal @parent, collection.parent
          assert_equal @array_collection, collection.object
        end

        def test_initialize_with_hash_collection
          collection = NamespaceCollection.new(:items, parent: @parent, collection: @hash_collection) do |item|
            # Block is required
          end
          
          assert_equal :items, collection.key
          assert_equal @parent, collection.parent
          assert_equal @hash_collection, collection.object
        end

        def test_each_with_array_collection
          namespaces = []
          NamespaceCollection.new(:items, parent: @parent, collection: @array_collection) do |namespace|
            namespaces << namespace
          end
          
          assert_equal 3, namespaces.length
          assert_instance_of MockParentNamespace, namespaces[0]
          assert_equal :"0", namespaces[0].key
          assert_equal @array_collection[0], namespaces[0].object
        end

        def test_each_with_hash_collection
          namespaces = []
          NamespaceCollection.new(:items, parent: @parent, collection: @hash_collection) do |namespace|
            namespaces << namespace
          end
          
          assert_equal 2, namespaces.length
          assert_instance_of MockParentNamespace, namespaces[0]
          assert_includes [:first, :second], namespaces[0].key
          assert_includes [@hash_collection[:first], @hash_collection[:second]], namespaces[0].object
        end

        def test_block_is_called_for_each_item
          call_count = 0
          NamespaceCollection.new(:items, parent: @parent, collection: @array_collection) do |namespace|
            call_count += 1
          end
          
          assert_equal 3, call_count
        end

        def test_created_namespaces_have_parent_set_to_collection
          collection = nil
          namespace = nil
          
          collection = NamespaceCollection.new(:items, parent: @parent, collection: @array_collection) do |ns|
            namespace = ns if namespace.nil?
          end
          
          assert_equal collection, namespace.parent
        end

        def test_created_namespaces_have_builder_klass_from_parent
          namespace = nil
          
          NamespaceCollection.new(:items, parent: @parent, collection: @array_collection) do |ns|
            namespace = ns if namespace.nil?
          end
          
          assert_equal @parent.builder_klass, namespace.builder_klass
        end
      end
    end
  end
end 