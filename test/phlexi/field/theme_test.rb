# frozen_string_literal: true

require "test_helper"

module Phlexi
  module Field
    class ThemeTest < Minitest::Test
      include ComponentTestHelper

      class TestTheme < Theme
        def self.theme
          {
            base: "base-class",
            button: "btn btn-primary",
            input: "form-control",
            error: "text-red-500",
            
            # Inherited themes
            email: :input,
            password: :input,
            
            # Nested inheritance
            primary_button: :button,
            danger_button: :primary_button,
            
            # Empty theme
            empty: nil
          }
        end
      end

      def setup
        @theme = TestTheme.new
      end

      def test_theme_is_frozen
        assert_predicate @theme.theme, :frozen?
      end

      def test_theme_returns_hash
        assert_instance_of Hash, @theme.theme
      end

      def test_resolve_direct_theme
        assert_equal "base-class", @theme.resolve_theme(:base)
        assert_equal "btn btn-primary", @theme.resolve_theme(:button)
        assert_equal "form-control", @theme.resolve_theme(:input)
      end

      def test_resolve_inherited_theme
        assert_equal "form-control", @theme.resolve_theme(:email)
        assert_equal "form-control", @theme.resolve_theme(:password)
      end

      def test_resolve_nested_inherited_theme
        assert_equal "btn btn-primary", @theme.resolve_theme(:primary_button)
        assert_equal "btn btn-primary", @theme.resolve_theme(:danger_button)
      end

      def test_resolve_non_existent_theme
        assert_nil @theme.resolve_theme(:non_existent)
      end

      def test_resolve_nil_theme
        assert_nil @theme.resolve_theme(nil)
      end

      def test_resolve_empty_theme
        assert_nil @theme.resolve_theme(:empty)
      end

      def test_resolve_handle_circular_reference
        circular_theme = TestTheme.new
        circular_theme.instance_variable_set(:@theme, {
          circular1: :circular2,
          circular2: :circular1
        }.freeze)
        
        assert_nil circular_theme.resolve_theme(:circular1)
      end

      def test_theme_class_required_implementation
        assert_raises(NotImplementedError) do
          Theme.theme
        end
      end
    end
  end
end 