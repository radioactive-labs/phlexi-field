# frozen_string_literal: true

require "test_helper"

module RailsComponentTestHelper
  include ComponentTestHelper

  # Render method that uses Rails view_context to render components or templates
  def render(component_or_template, **options)
    if component_or_template.is_a?(String)
      view_context.render(component_or_template, **options)
    else
      view_context.render(component_or_template)
    end
  end

  # Get the Rails view context
  def view_context
    controller.view_context
  end

  # Get the Rails test controller
  def controller
    @controller ||= ActionView::TestCase::TestController.new
  end

  # Simulate a form submission and return the parsed HTML response
  def submit_form(url, params = {})
    post url, params: params
    Nokogiri::HTML5(response.body)
  end
end 