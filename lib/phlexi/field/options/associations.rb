# frozen_string_literal: true

module Phlexi
  module Field
    module Options
      module Associations
        def association_reflection
          @association_reflection ||= find_association_reflection
        end

        protected

        def find_association_reflection
          if object.class.respond_to?(:reflect_on_association)
            object.class.reflect_on_association(key)
          end
        end
      end
    end
  end
end
