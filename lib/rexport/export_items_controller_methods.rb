# frozen_string_literal: true

module Rexport
  module ExportItemsControllerMethods
    def edit
      export_item
    end

    def update
      if export_item.update(export_item_params)
        redirect_to export_path(export_item.export), notice: "ExportItem was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      export_item.destroy
      redirect_to export_path(export_item.export)
    end

    private

    def export_item
      @export_item ||= ExportItem.find(params[:id])
    end

    def export_item_params
      params.require(:export_item).permit(:name)
    end
  end
end
