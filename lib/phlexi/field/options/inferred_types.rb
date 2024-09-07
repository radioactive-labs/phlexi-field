# frozen_string_literal: true

require "bigdecimal"

module Phlexi
  module Field
    module Options
      module InferredTypes
        def inferred_field_type
          @inferred_field_type ||= infer_field_type
        end

        def inferred_field_component
          @inferred_component ||= infer_field_component
        end

        private

        def infer_field_component
          case inferred_field_type
          when :string, :text
            infer_string_field_component(key)
          when :integer, :float, :decimal
            :number
          when :date, :datetime, :time
            :date
          when :boolean
            :boolean
          when :json, :jsonb, :hstore
            :code
          else
            if association_reflection
              :association
            elsif attachment_reflection
              :attachment
            else
              :text
            end
          end
        end

        def infer_field_type
          if object.class.respond_to?(:columns_hash)
            # ActiveRecord object
            column = object.class.columns_hash[key.to_s]
            return column.type if column
          end

          if object.class.respond_to?(:attribute_types)
            # ActiveModel::Attributes
            custom_type = object.class.attribute_types[key.to_s]
            return custom_type.type if custom_type&.type
          end

          # Check if object responds to the key
          if object.respond_to?(key)
            # Fallback to inferring type from the value
            return infer_field_type_from_value(object.send(key))
          end

          # Default to string if we can't determine the type
          :string
        end

        def infer_field_type_from_value(value)
          case value
          when Integer
            :integer
          when Float
            :float
          when BigDecimal
            :decimal
          when TrueClass, FalseClass
            :boolean
          when Date
            :date
          when Time, DateTime
            :datetime
          when Hash
            :json
          else
            :string
          end
        end

        def infer_string_field_component(key)
          key = key.to_s.downcase

          return :password if is_password_field?

          custom_type = custom_string_field_type(key)
          return custom_type if custom_type

          :text
        end

        def custom_string_field_type(key)
          custom_mappings = {
            /url$|^link|^site/ => :url,
            /^email/ => :email,
            /^search/ => :search,
            /phone|tel(ephone)?/ => :phone,
            /^time/ => :time,
            /^date/ => :date,
            /^number|_count$|_amount$/ => :number,
            /^color/ => :color
          }

          custom_mappings.each do |pattern, type|
            return type if key.match?(pattern)
          end

          nil
        end

        def is_password_field?
          key = self.key.to_s.downcase

          exact_matches = ["password"]
          prefixes = ["encrypted_"]
          suffixes = ["_password", "_digest", "_hash", "_token"]

          exact_matches.include?(key) ||
            prefixes.any? { |prefix| key.start_with?(prefix) } ||
            suffixes.any? { |suffix| key.end_with?(suffix) }
        end
      end
    end
  end
end
