# frozen_string_literal: true

module Phlexi
  module Field
    module Options
      module Hints
        def hint(hint = nil)
          if hint.nil?
            options[:hint]
          else
            options[:hint] = hint
            self
          end
        end

        def has_hint?
          hint.present?
        end
      end
    end
  end
end
