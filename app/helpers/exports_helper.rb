# frozen_string_literal: true

module ExportsHelper
  BOOLEAN_OPTIONS = [nil, ["true", 1], ["false", 0]].freeze
  FORM_TAG_CLASS = "form-control"

  def filter_value_field(rexport_model, field)
    ActiveSupport::Deprecation.warn(
      "Calling #filter_value_field is deprecated. Use #rexport_filter_form_tag instead"
    )
    rexport_filter_tag(@export, rexport_model, field) # rubocop:disable Rails/HelperInstanceVariable
  end

  def rexport_filter_tag(export, rexport_model, field) # rubocop:disable Metrics/MethodLength
    filter_field = rexport_model.field_path(rexport_model.filter_column(field))
    tag_name = "export[export_filter_attributes][#{filter_field}]"
    value = export.filter_value(filter_field)

    case field.type
    when :association
      association, text_method = field.method.split(".")
      association_filter_select_tag(
        tag_name,
        association_filter_options(
          rexport_model.collection_from_association(association),
          text_method,
          value
        )
      )
    when :boolean
      boolean_filter_select_tag(tag_name, value)
    when :date, :integer, :string
      text_field_tag(tag_name, value, class: FORM_TAG_CLASS)
    end
  end

  private

  def boolean_filter_select_tag(tag_name, value)
    select_tag(tag_name, options_for_select(BOOLEAN_OPTIONS, value&.to_i), class: FORM_TAG_CLASS)
  end

  def association_filter_options(collection, text_method, value)
    options_from_collection_for_select(collection, :id, text_method, value&.to_i)
  end

  def association_filter_select_tag(tag_name, options)
    select_tag(tag_name, options, include_blank: true, class: FORM_TAG_CLASS)
  end
end
