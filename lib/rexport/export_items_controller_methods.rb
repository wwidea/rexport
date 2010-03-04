module Rexport
  module ExportItemsControllerMethods
    # GET /export_item/1/edit
    def edit
      @export_item = ExportItem.find(params[:id])
    end
    
    # PUT /export_item/1
    def update
      @export_item = ExportItem.find(params[:id])
      
      respond_to do |format|
        if @export_item.update_attributes(params[:export_item])
          flash[:notice] = 'ExportItem was successfully updated.'
          format.html { redirect_to(export_path(@export_item.export)) }
        else
          format.html { render :action => "edit" }
        end
      end
    end
    
    # DELETE /export_item/1
    def destroy
      @export_item = ExportItem.find(params[:id])
      @export_item.destroy
      
      respond_to do |format|
        format.html { redirect_to(export_path(@export_item.export)) }
      end
    end
  end
end
