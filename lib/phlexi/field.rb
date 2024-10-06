# frozen_string_literal: true

require "zeitwerk"
require "phlex"
require "active_support/core_ext/object/blank"

module Phlexi
  NIL_VALUE = :__i_phlexi_i__

  module Field
    Loader = Zeitwerk::Loader.new.tap do |loader|
      loader.tag = File.basename(__FILE__, ".rb")
      loader.ignore("#{__dir__}/field/version.rb")
      loader.inflector.inflect(
        "phlexi-field" => "Phlexi",
        "phlexi" => "Phlexi",
        "dom" => "DOM"
      )
      loader.push_dir(File.expand_path("..", __dir__))
      loader.setup
    end

    COMPONENT_BASE = (defined?(::ApplicationComponent) ? ::ApplicationComponent : Phlex::HTML)

    class Error < StandardError; end

    def self.object_primary_key(object)
      if object.class.respond_to?(:primary_key)
        object.send(object.class.primary_key.to_sym)
      elsif object.respond_to?(:id)
        object.id
      end
    end
  end
end
