# frozen_string_literal: true

module Phlexi
  module Field
    module Components
      class Base < COMPONENT_BASE
        include Phlexi::Field::Common::Tokens

        attr_reader :field, :attributes

        def initialize(field, **attributes)
          @field = field
          @attributes = attributes

          build_attributes
          build_component_class
        end

        protected

        def build_attributes
          attributes.fetch(:id) { attributes[:id] = "#{field.dom.id}_#{component_name}" }
        end

        def build_component_class
          return if attributes[:class] == false

          attributes[:class] = tokens(component_name, attributes[:class])
        end

        def component_name
          @component_name ||= self.class.name.demodulize.underscore
        end
      end
    end
  end
end
