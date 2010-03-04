module Rexport
  module ExportsControllerMethods
    # GET /exports
    def index
      @exports = Export.categorical.alphabetical
      
      respond_to do |format|
        format.html # index.html.erb
      end
    end
    
    # GET /exports/1
    def show
      @export = Export.find(params[:id])
      
      respond_to do |format|
        format.html # show.html.erb
        format.csv { send_data(@export.to_csv, :type => content_type, :filename => filename) }
      end
    end
    
    # GET /exports/new
    def new
      @export = Export.new(params[:export])
      
      respond_to do |format|
        format.html # new.html.erb
      end
    end
    
    # GET /exports/1/edit
    def edit
      @export = Export.find(params[:id])
    end
    
    # POST /exports
    def create
      @export = params[:original_export_id] ? Export.find(params[:original_export_id]).copy : Export.new(params[:export])
      
      respond_to do |format|
        if @export.save
          flash[:notice] = 'Export was successfully created.'
          format.html { redirect_to(@export) }
        else
          format.html { render :action => "new" }
        end
      end
    end
    
    # PUT /exports/1
    def update
      @export = Export.find(params[:id])
      
      respond_to do |format|
        if @export.update_attributes(params[:export])
          flash[:notice] = 'Export was successfully updated.'
          format.html { redirect_to(@export) }
        else
          format.html { render :action => "edit" }
        end
      end
    end
    
    # DELETE /exports/1
    def destroy
      @export = Export.find(params[:id])
      @export.destroy
      
      respond_to do |format|
        format.html { redirect_to(exports_url) }
      end
    end
    
    #######
    private
    #######
    
    def content_type
      request.user_agent =~ /windows/i ? 'application/vnd.ms-excel' : 'text/csv'
    end
    
    def filename
      "#{@export.model_name}_#{@export.name.gsub(/ /, '_')}_#{Time.now.strftime('%Y%m%d')}.csv"
    end
  end
end
