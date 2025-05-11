# Phlexi::Field

[![Gem Version](https://badge.fury.io/rb/phlexi-field.svg)](https://badge.fury.io/rb/phlexi-field)
[![CI](https://github.com/radioactive-labs/phlexi-field/actions/workflows/main.yml/badge.svg)](https://github.com/radioactive-labs/phlexi-field/actions/workflows/main.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Phlexi::Field is a field component framework for Ruby applications that provides a unified field abstraction across forms, displays, and tables. Built on a namespace-based architecture for handling complex object relationships.
It's designed to work with [Phlex](https://github.com/phlex-ruby/phlex), a framework for building view components in Ruby.

## Design Philosophy & Purpose

Phlexi::Field serves as the foundation for field rendering across multiple contexts in web applications. Unlike traditional form builders that focus solely on forms, Phlexi::Field creates a unified abstraction for working with fields that can be used for:

- Form inputs
- Read-only displays
- Table columns
- Any other UI context where object fields are presented

It is designed around a **namespace-based architecture** that creates a hierarchical tree structure for complex object graphs, handling nested relationships and collections gracefully.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'phlexi-field'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install phlexi-field
```

## Requirements

- Ruby >= 3.2.2
- Phlex ~> 2.0
- ActiveSupport >= 7.1

## Core Architecture

### Namespace Pattern

The foundation of Phlexi::Field is the `Namespace` concept:

1. A Namespace maps an object (like an ActiveRecord model) to a key
2. Fields are created within a namespace
3. Namespaces can be nested to represent complex object relationships

```ruby
# Create a root namespace for a user object
namespace = Phlexi::Field::Structure::Namespace.new(
  :user,                           # The key/name 
  parent: nil,                     # Root namespace has no parent
  builder_klass: Phlexi::Field::Builder,  # Field builder class
  object: @user                    # The data object
)

# Create a field within the namespace
email_field = namespace.field(:email)

# Access field properties
email_field.dom.id      # => "user_email"
email_field.dom.name    # => "user[email]"
email_field.value       # => The email value from @user
```

### Nested Objects and Collections

One of Phlexi::Field's strengths is handling complex object graphs:

```ruby
# For a has_one relationship
namespace.nest_one(:profile) do |profile|
  first_name = profile.field(:first_name)
  # DOM properties: id="user_profile_first_name", name="user[profile][first_name]"
end

# For a has_many relationship
namespace.nest_many(:addresses) do |address_builder|
  street = address_builder.field(:street)
  # DOM properties: id="user_addresses_street", name="user[addresses][][street]"
end
```

### Field Builders and Components

Phlexi::Field separates field creation from rendering:

- `Builder` classes handle field creation, value access, and configuration
- `Component` classes handle presentation and rendering

This separation allows the same field structure to be rendered differently in various contexts.

## Field Configuration Options

Phlexi::Field provides a rich set of options for configuring how fields are displayed and behave:

### Labels

Labels can be explicitly set or automatically generated from the object's attribute name:

```ruby
# Custom label
field = namespace.field(:email, label: "Email Address")

# Get the current label (automatically falls back to humanized attribute name)
field.label  # => "Email Address" or "Email" if not explicitly set

# Rails integration: Uses human_attribute_name if available
# user.class.human_attribute_name(:email) => "Email Address"
```

### Hints and Descriptions

Hints provide contextual help for users, while descriptions offer more detailed explanations:

```ruby
# Setting a hint for a field
field = namespace.field(:password, hint: "Must be at least 8 characters")
field.hint  # => "Must be at least 8 characters"
field.has_hint?  # => true

# Setting a description
field = namespace.field(:terms_accepted, 
                      description: "By accepting our terms, you agree to our privacy policy.")
field.description  # => "By accepting our terms, you agree to our privacy policy."
field.has_description?  # => true
```

### Placeholders

Text placeholders can be set for input fields:

```ruby
field = namespace.field(:email, placeholder: "john@example.com")
field.placeholder  # => "john@example.com"
```

### Type Inference

Phlexi::Field automatically infers the appropriate field type based on multiple signals:

```ruby
# Based on attribute/column type in ActiveRecord/ActiveModel
# email_field.inferred_field_type  # => :string, :integer, :boolean, etc.

# For string fields, it can also infer more specific types
# email_field.inferred_string_field_type  # => :email, :password, :url, etc. 
```

The type inference algorithm considers:
1. ActiveRecord column types
2. ActiveModel attribute types  
3. Value type inspection
4. Field name conventions (email, password, url, etc.)
5. Validation rules (email format, numericality, etc.)

### Validators

When using ActiveModel validations, Phlexi::Field can access them:

```ruby
# Check if a field is required based on presence validators
field.required?  # => true/false based on presence validators

# Access the validation errors
field.errors  # => ["can't be blank", etc.]
```

### Multiple Options

For fields that support multiple selections:

```ruby
field = namespace.field(:categories, multiple: true)
field.multiple?  # => true
```

## Usage

Phlexi::Field provides a foundation for building components that handle object fields such as forms and other UI components. It handles DOM structure, field values, configuration of labels, descriptions, hints, and more.

It serves as a foundation for [Phlexi::Form](https://github.com/radioactive-labs/phlexi-form), [Phlexi::Display](https://github.com/radioactive-labs/phlexi-display) and [Phlexi::Table](https://github.com/radioactive-labs/phlexi-table).

### Basic Example

```ruby
class UserForm < Phlex::HTML
  def initialize(user)
    super()
    @user = user
  end
  
  def view_template
    namespace = Phlexi::Field::Structure::Namespace.new(
      :user, 
      parent: nil, 
      builder_klass: Phlexi::Field::Builder, 
      object: @user
    )
    
    form(action: "/users", method: "post") do
      # Create a name field
      name_field = namespace.field(:name)
      label(for: name_field.dom.id) { name_field.label }
      input(
        id: name_field.dom.id, 
        name: name_field.dom.name, 
        value: name_field.value, 
        type: "text"
      )
      
      # Create an email field
      email_field = namespace.field(:email)
      label(for: email_field.dom.id) { email_field.label }
      input(
        id: email_field.dom.id, 
        name: email_field.dom.name, 
        value: email_field.value, 
        type: "email"
      )
      
      # Submit button
      button(type: "submit") { "Submit" }
    end
  end
end

# Usage in a controller
def new
  user = User.new
  render UserForm.new(user)
end
```

### Nested Forms

Phlexi::Field supports nested forms for complex data structures:

```ruby
# For a has_one relationship
namespace.nest_one(:profile) do |profile|
  profile.field(:first_name) # => Creates a field for user[profile][first_name]
end

# For a has_many relationship
namespace.nest_many(:addresses) do |address_builder|
  address_field = address_builder.field(:id)
  # Creates fields like user[addresses][][id]
end
```

### Field Options

Fields support various options for customization:

```ruby
# Custom label
field = namespace.field(:email, label: "Email Address")

# Required fields
field = namespace.field(:email, required: true)

# Placeholder text
field = namespace.field(:email, placeholder: "Enter your email")

# Description/hint text
field = namespace.field(:password, hint: "Must be at least 8 characters")
```

## Components

Phlexi::Field comes with a base component architecture that you can extend:

```ruby
class MyInputComponent < Phlexi::Field::Components::Base
  def view_template
    input(
      id: field.dom.id,
      name: field.dom.name,
      value: field.value,
      type: "text",
      **attributes
    )
  end
end

# Usage
my_component = MyInputComponent.new(field, class: "custom-input")
render my_component
```

## Comparison with Other Libraries

Phlexi::Field differs from traditional Rails form helpers and gems like Simple Form in several key ways:

1. **Unified Field API**: Creates a consistent interface for fields across forms, displays, and tables
2. **Component-Based**: Built on Phlex's component system rather than Rails' helper-based approach
3. **Separation of Concerns**: Cleanly separates field structure (namespace), data handling (builder), and presentation (components)
4. **True Object Orientation**: Works with complete objects and their relationships rather than flat attribute lists

## Integration with Rails

While Phlexi::Field works standalone with Phlex, it has first-class support for Rails:

```ruby
# In your Gemfile
gem 'phlexi-field'
gem 'phlex-rails'
```

The library automatically uses Rails conventions when available:
- Humanized attribute names via `human_attribute_name`
- Association detection via `reflect_on_association`
- Primary key handling

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/radioactive-labs/phlexi-field.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
