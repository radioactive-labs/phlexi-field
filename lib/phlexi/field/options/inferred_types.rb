# frozen_string_literal: true

require "bigdecimal"

module Phlexi
  module Field
    module Options
      module InferredTypes
        def inferred_field_component
          @inferred_component ||= infer_field_component
        end

        def inferred_field_type
          @inferred_field_type ||= infer_field_type
        end

        def inferred_string_field_type
          @inferred_string_field_type || infer_string_field_type
        end

        private

        def infer_field_component
          case inferred_field_type
          when :string, :citext
            infer_string_field_type || :string
          when :text
            infer_string_field_type || inferred_field_type
          when :integer, :float, :decimal
            :number
          when :date, :datetime, :time
            :datetime
          when :boolean
            :boolean
          when :json, :jsonb, :hstore
            :code
          else
            inferred_field_type
          end
        end

        def infer_field_type
          if object.class.respond_to?(:defined_enums)
            return :enum if object.class.defined_enums.key?(key.to_s)
          end

          if object.class.respond_to?(:columns_hash)
            # ActiveRecord
            column = object.class.columns_hash[key.to_s]
            return column.type if column&.type
          end

          if object.class.respond_to?(:attribute_types)
            # ActiveModel::Attributes
            custom_type = object.class.attribute_types[key.to_s]
            return custom_type.type if custom_type&.type
          end

          # Check attachments first since they are implemented as associations
          return :attachment if attachment_reflection

          return :association if association_reflection

          # Check if object responds to the key
          if object.respond_to?(key)
            # Fallback to inferring type from the value
            return infer_field_type_from_value(object.send(key))
          end

          # Check if object is a has that contains key
          if object.respond_to?(:fetch)
            # Fallback to inferring type from the value
            return infer_field_type_from_value(object.fetch(key))
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

        def infer_string_field_type
          infer_string_field_type_from_key || infer_string_field_type_from_validations
        end

        def infer_string_field_type_from_validations
          return unless has_validators?

          if attribute_validators.find { |v| v.kind == :numericality }
            :number
          elsif attribute_validators.find { |v| v.kind == :format && v.options[:with] == URI::MailTo::EMAIL_REGEXP }
            :email
          end
        end

        def infer_string_field_type_from_key
          key = self.key.to_s.downcase
          return :password if is_password_field?(key)

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

        def is_password_field?(key)
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
