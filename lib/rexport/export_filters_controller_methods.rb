module Rexport
  module ExportFiltersControllerMethods
    def destroy
      @export_filter = ExportFilter.find(params[:id])
      @export_filter.destroy
      
      redirect_to @export_filter.export
    end
  end
end
