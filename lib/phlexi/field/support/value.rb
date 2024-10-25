module Phlexi
  module Field
    module Support
      module Value
        def self.from(object, key)
          return object[key] if object.is_a?(Hash)
          object.public_send(key) if object.respond_to?(key)
        end
      end
    end
  end
end
