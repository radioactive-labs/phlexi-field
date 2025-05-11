# Phlexi::Field

[![Gem Version](https://badge.fury.io/rb/phlexi-field.svg)](https://badge.fury.io/rb/phlexi-field)
[![CI](https://github.com/radioactive-labs/phlexi-field/actions/workflows/main.yml/badge.svg)](https://github.com/radioactive-labs/phlexi-field/actions/workflows/main.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Phlexi::Field is a Ruby gem that provides base field components for the Phlexi ecosystem. It's designed to work with [Phlex](https://github.com/phlex-ruby/phlex), a framework for building view components in Ruby.

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
