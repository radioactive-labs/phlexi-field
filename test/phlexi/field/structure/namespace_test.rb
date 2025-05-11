# frozen_string_literal: true

require "test_helper"

module Phlexi
  module Field
    module Structure
      class NamespaceTest < Minitest::Test
        include ComponentTestHelper

        class MockBuilderClass
          attr_reader :key, :parent, :object, :options

          def initialize(key, parent:, object: nil, **options)
            @key = key
            @parent = parent
            @object = object
            @options = options
          end
        end

        class MockUserObject
          attr_accessor :name, :email, :profile, :addresses

          def initialize(name: nil, email: nil, profile: nil, addresses: nil)
            @name = name
            @email = email
            @profile = profile
            @addresses = addresses
          end
        end

        class MockProfileObject
          attr_accessor :avatar, :bio

          def initialize(avatar: nil, bio: nil)
            @avatar = avatar
            @bio = bio
          end
        end

        class MockAddressObject
          attr_accessor :street, :city, :zip

          def initialize(street: nil, city: nil, zip: nil)
            @street = street
            @city = city
            @zip = zip
          end
        end

        def setup
          @profile = MockProfileObject.new(avatar: "avatar.jpg", bio: "Test bio")
          @addresses = [
            MockAddressObject.new(street: "123 Main St", city: "Anytown", zip: "12345"),
            MockAddressObject.new(street: "456 Oak Ave", city: "Somewhere", zip: "67890")
          ]
          @user = MockUserObject.new(
            name: "Test User",
            email: "test@example.com",
            profile: @profile,
            addresses: @addresses
          )
        end

        def test_initialize
          namespace = Namespace.new(:user, parent: nil, builder_klass: MockBuilderClass, object: @user)

          assert_equal :user, namespace.key
          assert_nil namespace.parent
          assert_equal MockBuilderClass, namespace.builder_klass
          assert_equal @user, namespace.object
        end

        def test_initialize_with_block
          block_called = false
          Namespace.new(:user, parent: nil, builder_klass: MockBuilderClass, object: @user) do |ns|
            block_called = true
            assert_equal @user, ns.object
          end

          assert block_called, "Block should be called during initialization"
        end

        def test_field
          namespace = Namespace.new(:user, parent: nil, builder_klass: MockBuilderClass, object: @user)
          field = namespace.field(:name)

          assert_instance_of MockBuilderClass, field
          assert_equal :name, field.key
          assert_equal namespace, field.parent
          assert_equal @user, field.object
        end

        def test_field_with_custom_builder
          namespace = Namespace.new(:user, parent: nil, builder_klass: MockBuilderClass, object: @user)
          custom_builder = Class.new(MockBuilderClass)
          field = namespace.field(:name, builder_klass: custom_builder)

          assert_instance_of custom_builder, field
        end

        def test_field_with_block
          namespace = Namespace.new(:user, parent: nil, builder_klass: MockBuilderClass, object: @user)
          block_called = false

          namespace.field(:name) do |f|
            block_called = true
            assert_equal :name, f.key
          end

          assert block_called, "Block should be called when creating a field"
        end

        def test_nest_one
          namespace = Namespace.new(:user, parent: nil, builder_klass: MockBuilderClass, object: @user)
          profile_namespace = namespace.nest_one(:profile) { |_| }

          assert_instance_of Namespace, profile_namespace
          assert_equal :profile, profile_namespace.key
          assert_equal namespace, profile_namespace.parent
          assert_equal @profile, profile_namespace.object
          assert_equal MockBuilderClass, profile_namespace.builder_klass
        end

        def test_nest_one_with_custom_key
          namespace = Namespace.new(:user, parent: nil, builder_klass: MockBuilderClass, object: @user)
          profile_namespace = namespace.nest_one(:profile, as: :user_profile) { |_| }

          assert_equal :user_profile, profile_namespace.key
          assert_equal @profile, profile_namespace.object
        end

        def test_nest_one_with_explicit_object
          namespace = Namespace.new(:user, parent: nil, builder_klass: MockBuilderClass, object: @user)
          custom_profile = MockProfileObject.new(bio: "Custom profile")
          profile_namespace = namespace.nest_one(:profile, object: custom_profile) { |_| }

          assert_equal custom_profile, profile_namespace.object
        end

        def test_nest_many
          namespace = Namespace.new(:user, parent: nil, builder_klass: MockBuilderClass, object: @user)
          # Provide a required block
          addresses_collection = namespace.nest_many(:addresses) { |_| }

          assert_instance_of Namespace::NamespaceCollection, addresses_collection
          assert_equal :addresses, addresses_collection.key
          assert_equal namespace, addresses_collection.parent
        end

        def test_nest_many_with_block
          namespace = Namespace.new(:user, parent: nil, builder_klass: MockBuilderClass, object: @user)
          namespaces = []

          namespace.nest_many(:addresses) do |address_namespace|
            namespaces << address_namespace
            # The key is the index in the array, not the collection name
            assert_includes [:"0", :"1"], address_namespace.key
          end

          assert_equal 2, namespaces.size
          assert_instance_of Namespace, namespaces.first
        end

        def test_each
          namespace = Namespace.new(:user, parent: nil, builder_klass: MockBuilderClass, object: @user)
          namespace.field(:name)
          namespace.field(:email)

          children = []
          namespace.each { |child| children << child }

          assert_equal 2, children.size
          assert_includes children.map(&:key), :name
          assert_includes children.map(&:key), :email
        end

        def test_dom_id_with_nil_object
          namespace = Namespace.new(:user, parent: nil, builder_klass: MockBuilderClass, object: nil)

          assert_equal "user", namespace.dom_id
        end

        def test_dom_id_with_explicit_dom_id
          namespace = Namespace.new(:user, parent: nil, builder_klass: MockBuilderClass, object: @user, dom_id: "custom_dom_id")

          assert_equal "custom_dom_id", namespace.dom_id
        end

        def test_root_factory_method
          root = Namespace.root(:user, builder_klass: MockBuilderClass, object: @user) { |_| }

          assert_instance_of Namespace, root
          assert_nil root.parent
          assert_equal :user, root.key
          assert_equal @user, root.object
        end
      end
    end
  end
end
