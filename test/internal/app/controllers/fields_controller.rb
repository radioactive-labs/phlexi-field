class FieldsController < ActionController::Base
  class UserForm < Phlex::HTML    
    def initialize(user)
      super()
      @user = user
    end
    
    def view_template
      namespace = Phlexi::Field::Structure::Namespace.new(:user, parent: nil, 
                                                      builder_klass: Phlexi::Field::Builder, 
                                                      object: @user)
      
      form(action: "/test", method: "post") do
        # Render a name field
        name_field = namespace.field(:name)
        label(for: name_field.dom.id) { name_field.label }
        input(id: name_field.dom.id, name: name_field.dom.name, value: name_field.value, type: "text")
        
        # Render an email field
        email_field = namespace.field(:email)
        label(for: email_field.dom.id) { email_field.label }
        input(id: email_field.dom.id, name: email_field.dom.name, value: email_field.value, type: "email")
        
        # Submit button
        button(type: "submit") { "Submit" }
      end
    end
  end

  def new
    user = OpenStruct.new(name: "Test User", email: "test@example.com")
    render UserForm.new(user)
  end
end
