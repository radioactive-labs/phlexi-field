# frozen_string_literal: true

require "test_helper"

module Phlexi
  module Field
    class NestedNamespaceTest < Minitest::Test
      include ComponentTestHelper

      class TestField < Builder
        def input_tag(**attributes)
          # Create a simple HTML class instance for rendering
          field_ref = self

          # Create a simple HTML component
          Class.new(::Phlex::HTML) do
            def initialize(field_ref, attributes)
              super()
              @field_ref = field_ref
              @attributes = attributes
            end

            def view_template
              input(id: @field_ref.dom.id, name: @field_ref.dom.name,
                value: @field_ref.value, **@attributes)
            end
          end.new(field_ref, attributes)
        end
      end

      class TestNamespace < Structure::Namespace
        def initialize(key, parent:, **options)
          super(key, parent: parent, builder_klass: TestField, **options)
        end
      end

      class NestedFormComponent < ::Phlex::HTML
        def initialize(user)
          super()
          @namespace = TestNamespace.new(:user, parent: nil, object: user) { |_| }
        end

        def view_template
          # Render user fields
          render @namespace.field(:name).input_tag(type: "text")
          render @namespace.field(:email).input_tag(type: "email")

          # Render nested profile fields
          profile_namespace = @namespace.nest_one(:profile) { |_| }
          render profile_namespace.field(:bio).input_tag(type: "text")
          render profile_namespace.field(:avatar).input_tag(type: "file")

          # Render nested address collection
          @namespace.nest_many(:addresses) do |address_namespace|
            render address_namespace.field(:street).input_tag(type: "text")
            render address_namespace.field(:city).input_tag(type: "text")
            render address_namespace.field(:zip).input_tag(type: "text")
          end
        end
      end

      class Profile
        attr_accessor :bio, :avatar
        def initialize(bio: nil, avatar: nil)
          @bio = bio
          @avatar = avatar
        end
      end

      class Address
        attr_accessor :street, :city, :zip
        def initialize(street: nil, city: nil, zip: nil)
          @street = street
          @city = city
          @zip = zip
        end
      end

      class User
        attr_accessor :name, :email, :profile, :addresses
        def initialize(name: nil, email: nil, profile: nil, addresses: [])
          @name = name
          @email = email
          @profile = profile
          @addresses = addresses
        end
      end

      def setup
        @profile = Profile.new(bio: "Test Bio", avatar: "avatar.jpg")
        @addresses = [
          Address.new(street: "123 Main St", city: "Anytown", zip: "12345"),
          Address.new(street: "456 Oak Ave", city: "Somewhere", zip: "67890")
        ]
        @user = User.new(
          name: "Test User",
          email: "test@example.com",
          profile: @profile,
          addresses: @addresses
        )
      end

      def test_renders_nested_fields
        component = NestedFormComponent.new(@user)
        html = render_fragment(component)

        # Test user fields
        name_input = find_one(html, "input#user_name")
        assert_equal "user[name]", get_attribute(name_input, "name")
        assert_equal "Test User", get_attribute(name_input, "value")

        email_input = find_one(html, "input#user_email")
        assert_equal "user[email]", get_attribute(email_input, "name")
        assert_equal "test@example.com", get_attribute(email_input, "value")

        # Test profile fields
        bio_input = find_one(html, "input#user_profile_bio")
        assert_equal "user[profile][bio]", get_attribute(bio_input, "name")
        assert_equal "Test Bio", get_attribute(bio_input, "value")

        avatar_input = find_one(html, "input#user_profile_avatar")
        assert_equal "user[profile][avatar]", get_attribute(avatar_input, "name")
        assert_equal "avatar.jpg", get_attribute(avatar_input, "value")

        # Test address collection fields
        street_inputs = find(html, "input[name^='user[addresses]'][name$='[street]']")
        assert_equal 2, street_inputs.size
        assert_equal "123 Main St", get_attribute(street_inputs[0], "value")
        assert_equal "456 Oak Ave", get_attribute(street_inputs[1], "value")

        city_inputs = find(html, "input[name^='user[addresses]'][name$='[city]']")
        assert_equal 2, city_inputs.size
        assert_equal "Anytown", get_attribute(city_inputs[0], "value")
        assert_equal "Somewhere", get_attribute(city_inputs[1], "value")

        zip_inputs = find(html, "input[name^='user[addresses]'][name$='[zip]']")
        assert_equal 2, zip_inputs.size
        assert_equal "12345", get_attribute(zip_inputs[0], "value")
        assert_equal "67890", get_attribute(zip_inputs[1], "value")
      end

      def test_renders_with_empty_collections
        user = User.new(name: "User without addresses")
        component = NestedFormComponent.new(user)
        html = render_fragment(component)

        # No address fields should be rendered
        street_inputs = find(html, "input[name^='user[addresses]'][name$='[street]']")
        assert_equal 0, street_inputs.size
      end

      def test_renders_with_nil_nested_object
        user = User.new(name: "User without profile")
        component = NestedFormComponent.new(user)
        html = render_fragment(component)

        # Profile fields should exist but have no values
        bio_input = find_one(html, "input#user_profile_bio")
        assert_equal "user[profile][bio]", get_attribute(bio_input, "name")
        assert_nil get_attribute(bio_input, "value")
      end
    end
  end
end
