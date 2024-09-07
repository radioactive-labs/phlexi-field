# frozen_string_literal: true

module Phlexi
  module Field
    module Options
      module Placeholders
        def placeholder(placeholder = nil)
          if placeholder.nil?
            options[:placeholder]
          else

            options[:placeholder] = placeholder
            self
          end
        end
      end
    end
  end
end
