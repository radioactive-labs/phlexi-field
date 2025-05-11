# frozen_string_literal: true

require "test_helper"

module Phlexi
  module Field
    module Structure
      class DOMTest < Minitest::Test
        include ComponentTestHelper

        class MockField
          attr_reader :key, :value, :parent

          def initialize(key:, value: nil, parent: nil)
            @key = key
            @value = value || key.to_s
            @parent = parent
          end
        end

        def test_value
          field = MockField.new(key: :test, value: 123)
          dom = DOM.new(field: field)

          assert_equal "123", dom.value
        end

        def test_id_with_single_level
          field = MockField.new(key: :test)
          dom = DOM.new(field: field)

          assert_equal "test", dom.id
        end

        def test_id_with_multiple_levels
          parent = MockField.new(key: :parent)
          child = MockField.new(key: :child, parent: parent)
          grandchild = MockField.new(key: :grandchild, parent: child)
          dom = DOM.new(field: grandchild)

          assert_equal "parent_child_grandchild", dom.id
        end

        def test_id_with_dom_id
          field = MockField.new(key: :test)
          def field.dom_id
            "custom_#{key}"
          end
          dom = DOM.new(field: field)

          assert_equal "custom_test", dom.id
        end

        def test_name_with_single_level
          field = MockField.new(key: :test)
          dom = DOM.new(field: field)

          assert_equal "test", dom.name
        end

        def test_name_with_multiple_levels
          parent = MockField.new(key: :parent)
          child = MockField.new(key: :child, parent: parent)
          grandchild = MockField.new(key: :grandchild, parent: child)
          dom = DOM.new(field: grandchild)

          assert_equal "parent[child][grandchild]", dom.name
        end

        def test_lineage
          parent = MockField.new(key: :parent)
          child = MockField.new(key: :child, parent: parent)
          grandchild = MockField.new(key: :grandchild, parent: child)
          dom = DOM.new(field: grandchild)

          lineage = dom.lineage.to_a
          assert_equal 3, lineage.size
          assert_equal :parent, lineage[0].key
          assert_equal :child, lineage[1].key
          assert_equal :grandchild, lineage[2].key
        end

        def test_inspect
          field = MockField.new(key: :test, value: "value")
          dom = DOM.new(field: field)

          expected = %(<#{DOM.name} id="test" name="test" value="value"/>)
          assert_equal expected, dom.inspect
        end
      end
    end
  end
end
