# frozen_string_literal: true

Rails.application.routes.draw do
  # singleton resources
  resource :export_item_sorting,  only: :update

  # collection resources
  resources :export_items,        only: %i(edit update destroy)
  resources :export_filters,      only: %i(edit update destroy)
  resources :exports do
    resources :export_filters, only: :new
  end
end
