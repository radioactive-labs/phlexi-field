require "fiber/local"

module Phlexi
  module Field
    class Theme
      def self.inherited(subclass)
        super
        subclass.extend Fiber::Local
      end

      # Retrieves the theme hash
      #
      # This method returns a hash containing theme definitions for various display components.
      # If a theme has been explicitly set in the options, it returns that. Otherwise, it
      # initializes and returns a default theme.
      #
      # The theme hash defines CSS classes or references to other theme keys for different
      # components, allowing for a flexible and inheritance-based theming system.
      #
      # @return [Hash] A hash containing theme definitions for display components
      #
      # @example Accessing the theme
      #   theme[:text]
      #   # => "text-gray-700 text-sm"
      #
      # @example Theme inheritance
      #   theme[:email] # Returns :text, indicating email inherits text's theme
      def self.theme
        raise NotImplementedError, "#{self} must implement #self.theme"
      end

      def theme
        @theme ||= self.class.theme.freeze
      end

      # Recursively resolves the theme for a given property, handling nested symbol references
      #
      # @param property [Symbol, String] The theme property to resolve
      # @param visited [Set] Set of already visited properties to prevent infinite recursion
      # @return [String, nil] The resolved theme value or nil if not found
      #
      # @example Basic usage
      #   # Assuming the theme is: { text: "text-gray-700", email: :text }
      #   themed(:text)
      #   # => "text-gray-700 text-sm"
      #
      # @example Cascading themes
      #   # Assuming the theme is: { text: "text-gray-700", email: :text }
      #   resolve_theme(:email)
      #   # => "text-gray-700"
      def resolve_theme(property, visited = Set.new)
        return nil if !property.present? || visited.include?(property)
        visited.add(property)

        result = theme[property]
        if result.is_a?(Symbol)
          resolve_theme(result, visited)
        else
          result
        end
      end
    end
  end
end
