# frozen_string_literal: true

module Phlexi
  module Field
    module Structure
      # Generates DOM IDs, names, etc. for a Field, Namespace, or Node based on
      # norms that were established by Rails. These can be used outside of or Rails in
      # other Ruby web frameworks since it has no dependencies on Rails.
      class DOM
        def initialize(field:)
          @field = field
        end

        # Converts the value of the field to a String, which is required to work
        # with Phlex. Assumes that `Object#to_s` emits a format suitable for display.
        def value
          @field.value.to_s
        end

        # Walks from the current node to the parent node, grabs the names, and separates
        # them with a `_` for a DOM ID.
        def id
          @id ||= begin
            root, *rest = lineage
            root_key = if root.respond_to?(:dom_id)
              root.dom_id
            else
              root.key
            end
            rest.map(&:key).unshift(root_key).join("_")
          end
        end

        # The `name` attribute of a node, which is influenced by Rails.
        # All node names, except the parent node, are wrapped in a `[]` and collections
        # are left empty. For example, `user[addresses][][street]` would be created for a form with
        # data shaped like `{user: {addresses: [{street: "Sesame Street"}]}}`.
        def name
          @name ||= begin
            root, *names = keys
            names.map { |name| "[#{name}]" }.unshift(root).join
          end
        end

        # One-liner way of walking from the current node all the way up to the parent.
        def lineage
          @lineage ||= Enumerator.produce(@field, &:parent).take_while(&:itself).reverse
        end

        # Emit the id, name, and value in an HTML tag-ish that doesnt have an element.
        def inspect
          "<#{self.class.name} id=#{id.inspect} name=#{name.inspect} value=#{value.inspect}/>"
        end

        private

        def keys
          @keys ||= lineage.map do |node|
            # If the parent of a field is a field, the name should be nil.
            node.key unless node.parent.is_a? Builder
          end
        end
      end
    end
  end
end
