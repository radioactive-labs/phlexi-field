# frozen_string_literal: true

module Phlexi
  module Field
    module Structure
      # Superclass for Namespace and Field classes. Represents a node in the field tree structure.
      #
      # @attr_reader [Symbol] key The node's key
      # @attr_reader [Node, nil] parent The node's parent in the tree structure
      class Node
        attr_reader :key, :parent

        # Initializes a new Node instance.
        #
        # @param key [Symbol, String] The key for the node
        # @param parent [Node, nil] The parent node
        def initialize(key, parent:)
          @key = :"#{key}"
          @parent = parent
        end

        def inspect
          "<#{self.class.name} key=#{key.inspect} object=#{object.inspect} parent=#{parent.inspect} />"
        end
      end
    end
  end
end
