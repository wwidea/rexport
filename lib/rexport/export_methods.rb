# frozen_string_literal: true

require "csv"

module Rexport # :nodoc:
  module ExportMethods
    extend ActiveSupport::Concern

    included do
      has_many :export_items,   dependent: :destroy
      has_many :export_filters, dependent: :destroy

      validates_presence_of :name, :model_class_name

      after_save :save_export_items

      scope :alphabetical,  -> { order :name }
      scope :categorical,   -> { order :model_class_name }
    end

    module ClassMethods
      def models
        %w[override_this_method]
      end
    end

    def full_name
      "#{model_class_name.pluralize} - #{name}"
    end

    # Returns a string with the export data
    def to_s
      records.unshift(header).map { |line| line.join("|") }.join("\n")
    end

    # Returns a csv string with the export data
    def to_csv(objects = nil)
      seed_records(objects) unless objects.nil?
      CSV.generate do |csv|
        csv << header
        records.each do |record|
          csv << record
        end
      end
    end

    # Returns an array with the header names from the associated export_items
    def header
      export_items.ordered.map(&:name)
    end

    # Returns the export model class
    def export_model
      model_class_name.constantize
    end

    # Returns a RexportModel for the current export_model
    def rexport_model
      @rexport_model ||= RexportModel.new(export_model)
    end

    # Returns an array of RexportModels including export_model and associated rexport capable models
    def rexport_models
      @rexport_models ||= get_rexport_models(export_model)
    end

    # Returns the records for the export
    def records
      @records ||= get_records
    end

    # Returns a limited number of records for the export
    def sample_records
      get_records(Rexport::SAMPLE_SIZE)
    end

    # Returns a class based on a path array
    def get_klass_from_path(path, klass = export_model)
      return klass unless (association_name = path.shift)

      get_klass_from_path(path, klass.reflect_on_association(association_name.to_sym).klass)
    end

    def rexport_field?(rexport_field)
      rexport_fields.include?(rexport_field)
    end

    # Stores rexport_field names to update the export_items association after save
    # Expects fields to be a hash with field names as the keys or an array of field names:
    # { "field_one" => "1", "field_two" => "1" }
    # ["field_one", "field_two"]
    def rexport_fields=(fields)
      @rexport_fields = extract_rexport_fields(fields).map(&:to_s)
    end

    def export_filter_attributes=(attributes)
      attributes.each do |field, value|
        if value.blank?
          export_filters.find_by(filter_field: field)&.destroy
        elsif new_record?
          export_filters.build(filter_field: field, value:)
        else
          export_filters.find_or_create_by(filter_field: field).update_attribute(:value, value)
        end
      end
    end

    def filter_value(filter_field)
      export_filters.detect { |f| f.filter_field == filter_field }&.value
    end

    def copy
      self.class.create(attributes_for_copy) do |new_export|
        export_items.ordered.each { |item| new_export.export_items.build(item.attributes_for_copy) }
        export_filters.each { |filter| new_export.export_filters.build(filter.attributes_for_copy) }
      end
    end

    private

    def get_records(limit = nil)
      get_export_values(export_model.where(build_conditions).includes(build_include).limit(limit))
    rescue ActiveRecord::StatementInvalid => e
      [[e.message]]
    end

    def seed_records(objects)
      @records = get_export_values(objects)
    end

    def get_export_values(objects)
      objects.map { |object| object.export(rexport_methods) }
    end

    def get_rexport_models(model, results = [], path = nil)
      return unless model.include?(Rexport::DataFields)

      results << RexportModel.new(model, path:)
      get_associations(model).each do |associated_model|
        # prevent infinite loop by checking if this class is already in the results set
        next if results.detect { |result| result.klass == associated_model.klass }

        get_rexport_models(associated_model.klass, results, [path, associated_model.name].compact * ".")
      end
      results
    end

    def get_associations(model)
      %i[belongs_to has_one].map do |type|
        model.reflect_on_all_associations(type)
      end.flatten.reject(&:polymorphic?)
    end

    def build_include
      root = Rexport::TreeNode.new("root")
      (rexport_methods + filter_fields).select { |m| m.include?(".") }.each do |method|
        root.add_child(method.split(".").values_at(0..-2))
      end
      root.to_include
    end

    def build_conditions
      {}.tap do |conditions|
        export_filters.each do |filter|
          conditions[get_database_field(filter.filter_field)] = filter.value
        end
      end
    end

    def get_database_field(field)
      path = field.split(".")
      field = path.pop
      "#{get_klass_from_path(path).table_name}.#{field}"
    end

    def rexport_methods
      @rexport_methods ||= rexport_model.get_rexport_methods(ordered_rexport_fields)
    end

    def rexport_fields
      @rexport_fields ||= export_items.map(&:rexport_field)
    end

    def ordered_rexport_fields
      export_items.ordered.map(&:rexport_field)
    end

    def filter_fields
      export_filters.map(&:filter_field)
    end

    def save_export_items
      export_items.where.not(rexport_field: rexport_fields).destroy_all

      rexport_fields.each.with_index(1) do |rexport_field, position|
        find_or_create_export_item(rexport_field).tap do |export_item|
          export_item.update_attribute(:position, position) if set_position
        end
      end
    end

    # Uses array find to search in memory export_items assocation instead of performing a SQL query on every iteration
    def find_or_create_export_item(rexport_field)
      export_items.find { |export_item| export_item.rexport_field == rexport_field } || export_items.create(rexport_field:)
    end

    def attributes_for_copy
      attributes.slice("model_class_name", "description").merge(name: find_unique_name(name))
    end

    def find_unique_name(original_name, suffix = 0)
      new_name = suffix.zero? ? "#{original_name} Copy" : "#{original_name} Copy [#{suffix}]"
      self.class.find_by(name: new_name) ? find_unique_name(original_name, suffix + 1) : new_name
    end

    def extract_rexport_fields(fields)
      # When fields is a hash return the keys and do not update export_item positions on save
      return fields.keys if fields.respond_to?(:keys)

      # When fields is an array update export item positions on save
      @set_position = true
      fields
    end

    def set_position
      @set_position ||= false
    end
  end
end
