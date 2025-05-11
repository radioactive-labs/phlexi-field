# frozen_string_literal: true

Rails.application.routes.draw do
  # Add your own routes here, or remove this file if you don't have need for it.
  resources :tests, only: [:create]
  resources :fields, only: [:new]
end
