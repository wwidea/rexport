module Rexport
  module ExportFiltersControllerMethods
    # DELETE /export_filters/1
    def destroy
      @export_filter = ExportFilter.find(params[:id])
      @export_filter.destroy

      respond_to do |format|
        format.html { redirect_to(@export_filter.export) }
      end
    end
  end
end