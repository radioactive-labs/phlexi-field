# frozen_string_literal: true

module Phlexi
  module Field
    module Structure
      # A Namespace maps an object to values, but doesn't actually have a value itself. For
      # example, a `User` object or ActiveRecord model could be passed into the `:user` namespace.
      #
      # To access single values on a Namespace, #field can be used.
      #
      # To access nested objects within a namespace, two methods are available:
      #
      # 1. #nest_one: Used for single nested objects, such as if a `User belongs_to :profile` in
      #    ActiveRecord. This method returns another Namespace object.
      #
      # 2. #nest_many: Used for collections of nested objects, such as if a `User has_many :addresses` in
      #    ActiveRecord. This method returns a NamespaceCollection object.
      class Namespace < Structure::Node
        include Enumerable

        class NamespaceCollection < Structure::NamespaceCollection; end

        attr_reader :builder_klass, :object

        def initialize(key, parent:, builder_klass:, object: nil, dom_id: nil)
          super(key, parent: parent)
          @builder_klass = builder_klass
          @object = object
          @dom_id = dom_id
          @children = {}
          yield self if block_given?
        end

        def field(key, template: false, **attributes)
          create_child(key, attributes.delete(:builder_klass) || builder_klass, object: object, template:, **attributes).tap do |field|
            yield field if block_given?
          end
        end

        # Creates a `Namespace` child instance with the parent set to the current instance, adds to
        # the `@children` Hash to ensure duplicate child namespaces aren't created, then calls the
        # method on the `@object` to get the child object to pass into that namespace.
        #
        # For example, if a `User#permission` returns a `Permission` object, we could map that to a
        # form like this:
        #
        # ```ruby
        # Phlexi::Form(User.new, as: :user) do
        #   nest_one :profile do |profile|
        #     render profile.field(:gender).input_tag
        #   end
        # end
        # ```
        def nest_one(key, as: nil, object: nil, default: nil, template: false, &)
          object ||= object_value_for(key: key) || default
          key = as || key
          create_child(key, self.class, object:, template:, builder_klass:, &)
        end

        # Wraps an array of objects in Namespace classes. For example, if `User#addresses` returns
        # an enumerable or array of `Address` classes:
        #
        # ```ruby
        # Phlexi::Form(User.new) do
        #   render field(:email).input_tag
        #   render field(:name).input_tag
        #   nest_many :addresses do |address|
        #     render address.field(:street).input_tag
        #     render address.field(:state).input_tag
        #     render address.field(:zip).input_tag
        #   end
        # end
        # ```
        # The object within the block is a `Namespace` object that maps each object within the enumerable
        # to another `Namespace` or `Field`.
        def nest_many(key, as: nil, collection: nil, default: nil, template: false, &)
          collection ||= Array(object_value_for(key: key)).presence || default
          key = as || key
          create_child(key, self.class::NamespaceCollection, collection:, template:, &)
        end

        # Iterates through the children of the current namespace, which could be `Namespace` or `Field`
        # objects.
        def each(&)
          @children.values.each(&)
        end

        def dom_id
          @dom_id ||= begin
            object_id = if object.nil?
              nil
            elsif (primary_key = Phlexi::Field.object_primary_key(object))
              primary_key&.to_s || :new
            end
            [key, object_id].compact.join("_").underscore
          end
        end

        # Creates a root Namespace.
        def self.root(*, builder_klass:, **, &)
          new(*, parent: nil, builder_klass:, **, &)
        end

        protected

        def object_value_for(key:)
          Phlexi::Field::Support::Value.from(@object, key)
        end

        private

        # Checks if the child exists. If it does then it returns that. If it doesn't, it will
        # build the child.
        def create_child(key, child_class, template: false, **, &)
          if template
            child_class.new(key, parent: self, **, &)
          else
            @children.fetch(key) { @children[key] = child_class.new(key, parent: self, **, &) }
          end
        end
      end
    end
  end
end
