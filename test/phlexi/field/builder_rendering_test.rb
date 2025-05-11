# frozen_string_literal: true

require "test_helper"

module Phlexi
  module Field
    class BuilderRenderingTest < Minitest::Test
      include ComponentTestHelper

      class TestField < Builder
        def label_tag(**attributes)
          # Create a simple HTML class instance for rendering
          field_ref = self
          id_value = attributes[:id] || "#{field_ref.dom.id}_label"
          class_value = attributes[:class]
          label_text = field_ref.options[:label] || field_ref.key.to_s.humanize

          # Create a simple HTML component
          Class.new(::Phlex::HTML) do
            def initialize(field_ref, id_value, class_value, label_text)
              super()
              @field_ref = field_ref
              @id_value = id_value
              @class_value = class_value
              @label_text = label_text
            end

            def view_template
              label(id: @id_value, class: @class_value, for: @field_ref.dom.id) do
                @label_text
              end
            end
          end.new(field_ref, id_value, class_value, label_text)
        end

        def input_tag(**attributes)
          # Create a simple HTML class instance for rendering
          field_ref = self

          # Create a simple HTML component
          Class.new(::Phlex::HTML) do
            def initialize(field_ref, attributes)
              super()
              @field_ref = field_ref
              @attributes = attributes
            end

            def view_template
              input(id: @field_ref.dom.id, name: @field_ref.dom.name,
                value: @field_ref.value, **@attributes)
            end
          end.new(field_ref, attributes)
        end
      end

      class TestNamespace < Structure::Namespace
        def initialize(key, parent:, **options)
          super(key, parent: parent, builder_klass: TestField, **options)
        end
      end

      class TestComponent < ::Phlex::HTML
        def initialize(object = nil)
          super()
          @namespace = TestNamespace.new(:root, parent: nil, object: object) { |_| }
        end

        def view_template
          render @namespace.field(:name).label_tag
          render @namespace.field(:name).input_tag(type: "text")

          render @namespace.field(:email).label_tag
          render @namespace.field(:email).input_tag(type: "email")
        end
      end

      def test_renders_field_components
        user = OpenStruct.new(name: "Test User", email: "test@example.com")
        component = TestComponent.new(user)

        html = render_fragment(component)

        # Test generated labels
        name_label = find_one(html, "label#root_name_label")
        assert_equal "root_name", get_attribute(name_label, "for")
        assert_equal "Name", name_label.text.strip

        email_label = find_one(html, "label#root_email_label")
        assert_equal "root_email", get_attribute(email_label, "for")
        assert_equal "Email", email_label.text.strip

        # Test generated inputs
        name_input = find_one(html, "input#root_name")
        assert_equal "root[name]", get_attribute(name_input, "name")
        assert_equal "Test User", get_attribute(name_input, "value")
        assert_equal "text", get_attribute(name_input, "type")

        email_input = find_one(html, "input#root_email")
        assert_equal "root[email]", get_attribute(email_input, "name")
        assert_equal "test@example.com", get_attribute(email_input, "value")
        assert_equal "email", get_attribute(email_input, "type")
      end

      def test_renders_with_nil_values
        component = TestComponent.new(nil)

        html = render_fragment(component)

        # Inputs exist but have no values
        name_input = find_one(html, "input#root_name")
        assert_equal "root[name]", get_attribute(name_input, "name")
        assert_nil get_attribute(name_input, "value")

        email_input = find_one(html, "input#root_email")
        assert_equal "root[email]", get_attribute(email_input, "name")
        assert_nil get_attribute(email_input, "value")
      end

      def test_renders_with_custom_label
        user = OpenStruct.new(name: "Test User")

        # Create a namespace with a custom label
        namespace = TestNamespace.new(:root, parent: nil, object: user) { |_| }
        field = namespace.field(:name, label: "Custom Label")

        html = render_fragment(field.label_tag)

        label = find_one(html, "label")
        assert_equal "Custom Label", label.text.strip
      end
    end
  end
end
