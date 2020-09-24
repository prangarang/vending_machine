# frozen_string_literal: true

Rails.application.routes.draw do
  resources :denominations
  resources :products
  resources :checkouts, only: [:create, :update, :show]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
