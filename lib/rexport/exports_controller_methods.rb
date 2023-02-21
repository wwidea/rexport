# frozen_string_literal: true

module Rexport
  module ExportsControllerMethods
    def index
      @exports = Export.categorical.alphabetical
    end

    def show
      export

      respond_to do |format|
        format.html # show.html.erb
        format.csv { send_data(export.to_csv, type: export_content_type, filename: filename) }
      end
    end

    def new
      @export = Export.new(export_params)
    end

    def edit
      export
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
      if export.update(export_params)
        redirect_to export, notice: 'Export was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      export.destroy

      redirect_to exports_url
    end

    private

    def export
      @export ||= Export.find(params[:id])
    end

    def export_params
      params.require(:export).permit(permitted_params)
    end

    def permitted_params
      [
        :name,
        :model_class_name,
        :description,
        rexport_fields: {},
        export_filter_attributes: {}
      ]
    end

    def export_content_type
      request.user_agent =~ /windows/i ? 'application/vnd.ms-excel' : 'text/csv'
    end

    def filename
      "#{export.model_class_name}_#{export.name.gsub(/ /, '_')}_#{Time.now.strftime('%Y%m%d')}.csv"
    end
  end
end
