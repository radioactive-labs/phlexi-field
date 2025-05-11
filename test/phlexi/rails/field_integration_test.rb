# frozen_string_literal: true

require "test_helper"
require "ostruct"

return if skip_integration_tests?

module Phlexi
  module Field
    class FieldIntegrationTest < ActionDispatch::IntegrationTest
      include ::Rails.application.routes.url_helpers
      include ComponentTestHelper

      def test_field_component_renders
        get new_field_path
        assert_response :success

        # Render the component
        output = response.body

        # Parse the output
        doc = Nokogiri::HTML.fragment(output)

        # Test that the fields were rendered correctly
        assert_equal 1, doc.css("form[action='/test']").size
        assert_equal 1, doc.css("input[name='user[name]'][value='Test User']").size
        assert_equal 1, doc.css("input[name='user[email]'][value='test@example.com']").size
        assert_equal 1, doc.css("button[type='submit']").size

        # Test DOM ID generation
        name_field_id = doc.css("input[name='user[name]']").first["id"]
        assert_match(/user_name/, name_field_id)

        email_field_id = doc.css("input[name='user[email]']").first["id"]
        assert_match(/user_email/, email_field_id)
      end
    end
  end
end
