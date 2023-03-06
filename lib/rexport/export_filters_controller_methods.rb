# frozen_string_literal: true

module Rexport
  module ExportFiltersControllerMethods
    def destroy
      export_filter.destroy
      redirect_to export_filter.export
    end

    private

    def export_filter
      @export_filter ||= ExportFilter.find(params[:id])
    end
  end
end
