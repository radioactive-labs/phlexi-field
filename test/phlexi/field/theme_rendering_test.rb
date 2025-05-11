# frozen_string_literal: true

require "test_helper"

module Phlexi
  module Field
    class ThemeRenderingTest < Minitest::Test
      include ComponentTestHelper

      class TestTheme < Theme
        def self.theme
          {
            input: "form-control",
            label: "form-label",
            
            # Typed inputs
            text: :input,
            email: :input,
            password: "form-control password-field",
            
            # Element states
            error: "is-invalid",
            valid: "is-valid",
            
            # Components
            form_group: "mb-3",
            button: "btn btn-primary"
          }
        end
      end

      class ThemedComponent < ::Phlex::HTML
        def initialize(theme = TestTheme.new)
          super()
          @theme = theme
        end

        def view_template
          # Basic input
          input_classes = @theme.resolve_theme(:input)
          input(type: "text", class: input_classes)

          # Typed input inheriting from base input
          email_classes = @theme.resolve_theme(:email)
          input(type: "email", class: email_classes)

          # Typed input with custom class
          password_classes = @theme.resolve_theme(:password)
          input(type: "password", class: password_classes)
          
          # Component with state
          input_with_error = "#{@theme.resolve_theme(:input)} #{@theme.resolve_theme(:error)}"
          input(type: "text", class: input_with_error)
          
          # Simple component
          button_classes = @theme.resolve_theme(:button)
          button(class: button_classes) { "Submit" }
          
          # Form group test
          div(class: @theme.resolve_theme(:form_group)) do
            label(class: @theme.resolve_theme(:label)) { "Test label" }
          end
        end
      end

      def test_renders_with_theme
        component = ThemedComponent.new
        html = render_fragment(component)
        
        inputs = find(html, "input")
        
        # Base input has form-control class
        text_input = inputs[0]
        assert_equal "form-control", get_attribute(text_input, "class")
        
        # Email input inherits from input class
        email_input = inputs[1]
        assert_equal "form-control", get_attribute(email_input, "class")
        
        # Password has custom classes
        password_input = inputs[2]
        assert_equal "form-control password-field", get_attribute(password_input, "class")
        
        # Input with error has combined classes
        error_input = inputs[3]
        assert_equal "form-control is-invalid", get_attribute(error_input, "class")
        
        # Button has the theme button class
        button = find_one(html, "button")
        assert_equal "btn btn-primary", get_attribute(button, "class")
        assert_equal "Submit", button.text.strip
        
        # Form group has correct class
        assert_element_exists(html, "div.mb-3")
        
        # Label has correct class
        assert_element_exists(html, "label.form-label")
      end
      
      def test_renders_with_custom_theme
        custom_theme = TestTheme.new
        def custom_theme.theme
          {
            input: "custom-input",
            text: "custom-text",
            form_group: "custom-group",
            label: "custom-label",
            button: "custom-button"
          }
        end
        
        component = ThemedComponent.new(custom_theme)
        html = render_fragment(component)
        
        # Check that custom theme classes are applied
        assert_element_exists(html, "div.custom-group")
        assert_element_exists(html, "label.custom-label")
        
        # Check input has custom class
        input = find_one(html, "input[type='text']")
        assert_equal "custom-input", get_attribute(input, "class")
        
        # Check button has custom class
        button = find_one(html, "button") 
        assert_equal "custom-button", get_attribute(button, "class")
      end
      
      def test_handles_missing_theme_keys
        # Create a theme with some keys missing
        custom_theme = TestTheme.new
        def custom_theme.theme
          {
            form_group: "custom-group",
            button: "custom-button"
          }
        end
        
        component = ThemedComponent.new(custom_theme)
        html = render_fragment(component)
        
        # Check that the keys that do exist work
        assert_element_exists(html, "div.custom-group")
        button = find_one(html, "button")
        assert_equal "custom-button", get_attribute(button, "class")
        
        # Keys that don't exist should be nil
        text_input = find(html, "input")[0]
        assert_nil get_attribute(text_input, "class")
      end
    end
  end
end 