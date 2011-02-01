Rails.application.routes.draw do
  # singleton resources
  resource :export_item_sorting,  :only => [:update]
  
  # collection resources
  resources :export_items,        :only => [:edit, :update, :destroy]
  resources :export_filters,      :only => [:edit, :update, :destroy]
  resources :exports do
    resources :export_filters, :only => [:new]
  end
end