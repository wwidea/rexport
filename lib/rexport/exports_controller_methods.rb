module Rexport
  module ExportsControllerMethods
    def index
      @exports = Export.categorical.alphabetical
    end
    
    def show
      @export = Export.find(params[:id])
      
      respond_to do |format|
        format.html # show.html.erb
        format.csv { send_data(@export.to_csv, :type => export_content_type, :filename => filename) }
      end
    end
    
    def new
      @export = Export.new(export_params)
    end
    
    def edit
      @export = Export.find(params[:id])
    end
    
    def create
      @export = params[:original_export_id] ? Export.find(params[:original_export_id]).copy : Export.new(export_params)
      
      if @export.save
        redirect_to @export, notice: 'Export was successfully created.'
      else
        render :new
      end
    end
    
    def update
      @export = Export.find(params[:id])
      
      if @export.update_attributes(export_params)
        redirect_to @export, notice: 'Export was successfully updated.'
      else
        render :edit
      end
    end
    
    def destroy
      @export = Export.find(params[:id])
      @export.destroy
      
      redirect_to exports_url
    end
    
    private
    
    def export_params
      params.require(:export).permit(:name, :model_class_name, :description).merge(rexport_fields: rexport_fields, export_filter_attributes: export_filter_attributes)
    end
    
    def rexport_fields
      permit_all params[:export][:rexport_fields]
    end
    
    def export_filter_attributes
      permit_all params[:export][:export_filter_attributes]
    end
    
    def permit_all(params)
      params ? params.permit! : []
    end
    
    def export_content_type
      request.user_agent =~ /windows/i ? 'application/vnd.ms-excel' : 'text/csv'
    end
    
    def filename
      "#{@export.model_class_name}_#{@export.name.gsub(/ /, '_')}_#{Time.now.strftime('%Y%m%d')}.csv"
    end
  end
end
