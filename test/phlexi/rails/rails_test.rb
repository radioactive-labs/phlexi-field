# frozen_string_literal: true

require "test_helper"

return if skip_integration_tests?

module Phlexi
  module Rails
    class RailsTest < ActionDispatch::IntegrationTest
      include ::Rails.application.routes.url_helpers

      def test_rails_integration
        post tests_path, params: {marco: :polo}
        assert_response :success
        assert_equal "OK", response.body
      end
    end
  end
end
