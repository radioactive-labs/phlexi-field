# frozen_string_literal: true

module Phlexi
  module Field
    module Options
      module Descriptions
        def description(description = nil)
          if description.nil?
            options[:description]
          else
            options[:description] = description
            self
          end
        end

        def has_description?
          description.present?
        end
      end
    end
  end
end
