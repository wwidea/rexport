ActionController::Routing::Routes.draw do |map|
  # singleton resources
  map.resource :export_item_sorting,  :only => [:update]
  
  # collection resources
  map.resources :export_items,        :only => [:edit, :update, :destroy]
  map.resources :export_filters,      :only => [:edit, :update, :destroy]
  map.resources :exports do |exports|
    exports.resources :export_filters, :only => [:new]
  end
end