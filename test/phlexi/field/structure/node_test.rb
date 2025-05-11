# frozen_string_literal: true

require "test_helper"

module Phlexi
  module Field
    module Structure
      class NodeTest < Minitest::Test
        include ComponentTestHelper

        class MockParent
          attr_reader :key
          def initialize(key = :parent)
            @key = key
          end

          def object
            "parent_object"
          end

          def inspect
            "<MockParent>"
          end
        end

        def test_initialize_with_string_key
          parent = MockParent.new
          node = Node.new("test", parent: parent)

          assert_equal :test, node.key
          assert_equal parent, node.parent
        end

        def test_initialize_with_symbol_key
          parent = MockParent.new
          node = Node.new(:test, parent: parent)

          assert_equal :test, node.key
          assert_equal parent, node.parent
        end

        def test_inspect
          parent = MockParent.new
          node = Node.new(:test, parent: parent)

          # Define method on the node for testing inspect
          def node.object
            "test_object"
          end

          expected = "<#{Node.name} key=:test object=\"test_object\" parent=<MockParent> />"
          assert_equal expected, node.inspect
        end
      end
    end
  end
end
