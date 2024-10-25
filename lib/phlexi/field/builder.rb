# frozen_string_literal: true

require "phlex"

module Phlexi
  module Field
    # Builder class is responsible for building fields with various options and components.
    #
    # @attr_reader [Structure::DOM] dom The DOM structure for the field.
    # @attr_reader [Hash] options Options for the field.
    # @attr_reader [Object] object The object associated with the field.
    # @attr_reader [Hash] attributes Attributes for the field.
    # @attr_accessor [Object] value The value of the field.
    class Builder < Structure::Node
      include Phlex::Helpers
      include Options::Validators
      include Options::InferredTypes
      include Options::Multiple
      include Options::Labels
      include Options::Placeholders
      include Options::Descriptions
      include Options::Hints
      include Options::Associations
      include Options::Attachments

      class DOM < Structure::DOM; end

      class FieldCollection < Structure::FieldCollection; end

      attr_reader :dom, :options, :object, :value

      # Initializes a new FieldBuilder instance.
      #
      # @param key [Symbol, String] The key for the field.
      # @param parent [Structure::Namespace] The parent object.
      # @param object [Object, nil] The associated object.
      # @param value [Object] The initial value for the field.
      # @param options [Hash] Additional options for the field.
      def initialize(key, parent:, object: nil, value: NIL_VALUE, **options)
        super(key, parent: parent)

        @object = object
        @value = determine_initial_value(value)
        @options = options
        @dom = self.class::DOM.new(field: self)
      end

      # Creates a repeated field collection.
      #
      # @param range [#each] The collection of items to generate displays for.
      # @yield [block] The block to be executed for each item in the collection.
      # @return [FieldCollection] The field collection.
      def repeated(collection = nil, &)
        self.class::FieldCollection.new(field: self, collection:, &)
      end

      def has_value?
        attachment_reflection.present? ? value.attached? : (value.present? || value == false)
      end

      protected

      def determine_initial_value(value)
        return value unless value == NIL_VALUE

        determine_value_from_object
      end

      def determine_value_from_object
        Phlexi::Field::Support::Value.from(object, key)
      end
    end
  end
end
