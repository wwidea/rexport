module Rexport
  module ExportItemSortingsControllerMethods
    def update
      ExportItem.resort(params[:sorted_items])
    
      respond_to do |format|
        format.js do
          head :ok
        end
      end
    end
  end
end
