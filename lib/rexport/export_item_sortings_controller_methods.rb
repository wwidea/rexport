module Rexport
  module ExportItemSortingsControllerMethods
    def update
      ExportItem.resort(params[:export_items])
    
      respond_to do |format|
        format.js do
          render :nothing => true
        end
      end
    end
  end
end
