module ExportsHelper
  def filter_value_field(rexport_model, field)
    filter_field = rexport_model.field_path(rexport_model.filter_column(field))
    tag_name = "export[export_filter_attributes][#{filter_field.to_s}]"
    value = @export.filter_value(filter_field)

    case field.type
      when :boolean
        select_tag(tag_name, options_for_select([nil, true, false], (value.to_i unless value.nil?)))
      when :association
        association, text_method = field.method.split('.')
        select_tag( tag_name,
              '<option value=""></option>' +
              options_from_collection_for_select(
                rexport_model.collection_from_association(association),
                :id,
                text_method,
                value.to_i))
      when :datetime, nil
        '&nbsp;'
      else
        text_field_tag(tag_name, value)
    end
  end
end
