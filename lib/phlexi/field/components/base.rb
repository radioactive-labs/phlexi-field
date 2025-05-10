# frozen_string_literal: true

module Phlexi
  module Field
    module Components
      class Base < COMPONENT_BASE
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

          base_class = component_name
          existing_class = attributes[:class]
          attributes[:class] = existing_class ? "#{base_class} #{existing_class}" : base_class
        end

        def component_name
          @component_name ||= self.class.name.demodulize.underscore
        end
      end
    end
  end
end
