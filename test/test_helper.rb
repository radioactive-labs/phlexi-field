# frozen_string_literal: true

require "phlexi-field"

require "minitest/autorun"
require "minitest/reporters"
Minitest::Reporters.use!

require "nokogiri"
require "ostruct"

module ComponentTestHelper
  # Basic render method that returns the HTML output of a component
  def render(component)
    component.call.to_s
  rescue => e
    warn "Error rendering component: #{component.class.name}, Error: #{e.message}"
    warn e.backtrace.first(5).join("\n")
    ""
  end

  # Parse HTML as a fragment
  def render_fragment(component_or_html)
    html = component_or_html.is_a?(String) ? component_or_html : render(component_or_html)
    Nokogiri::HTML5.fragment(html)
  end

  # Parse HTML as a complete document
  def render_document(component_or_html)
    html = component_or_html.is_a?(String) ? component_or_html : render(component_or_html)
    Nokogiri::HTML5(html)
  end

  # Find elements using CSS selectors
  def find(fragment, selector)
    fragment.css(selector)
  end

  # Find a single element using CSS selector
  def find_one(fragment, selector)
    result = find(fragment, selector)
    result&.first
  end

  # Get attribute value from an element
  def get_attribute(element, attribute_name)
    element[attribute_name] if element
  end

  # Get text content from an element
  def get_text(element)
    element&.text&.strip
  end

  # Check if element exists
  def element_exists?(fragment, selector)
    !find(fragment, selector).empty?
  end

  # Count elements matching a selector
  def count_elements(fragment, selector)
    find(fragment, selector).size
  end

  # Assert that element exists
  def assert_element_exists(fragment, selector, message = nil)
    message ||= "Expected to find element matching '#{selector}', but none was found."
    assert element_exists?(fragment, selector), message
  end

  # Assert that element doesn't exist
  def refute_element_exists(fragment, selector, message = nil)
    message ||= "Expected not to find element matching '#{selector}', but one was found."
    refute element_exists?(fragment, selector), message
  end

  # Assert element has attribute with value
  def assert_attribute(fragment, selector, attribute, value, message = nil)
    element = find_one(fragment, selector)
    message ||= "Expected element matching '#{selector}' to have attribute '#{attribute}' with value '#{value}'"
    assert_equal value, get_attribute(element, attribute), message
  end

  # Assert element contains text
  def assert_text(fragment, selector, text, message = nil)
    element = find_one(fragment, selector)
    message ||= "Expected element matching '#{selector}' to contain text '#{text}'"
    assert_includes get_text(element), text, message
  end
end

def gem_present?(gem_name)
  Gem::Specification.find_all_by_name(gem_name).any?
end

def skip_integration_tests?
  ENV["BUNDLE_GEMFILE"]&.include?("default.gemfile") || !gem_present?("phlex-rails")
end

return if skip_integration_tests?

require "combustion"
Combustion.path = "test/internal"
Combustion.initialize! :active_record, :action_controller

Rails.application.config.action_dispatch.show_exceptions = :none
