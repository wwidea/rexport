# frozen_string_literal: true

module Rexport # :nodoc:
  class RexportModel
    attr_accessor :klass, :path

    delegate :name, to: :klass

    def initialize(klass, path: nil)
      self.klass = klass
      self.path = path&.to_s
      initialize_rexport_fields
    end

    def rexport_fields
      @rexport_fields ||= ActiveSupport::HashWithIndifferentAccess.new
    end

    def rexport_fields_array
      rexport_fields.values.sort
    end

    def field_path(field_name)
      [path, field_name].compact * "."
    end

    def collection_from_association(association)
      klass.try(:"find_#{association}_for_rexport") || all_objects_from(association)
    end

    def filter_column(field)
      foreign_key_for(field.association_name) || field.method
    end

    # Adds a data item to rexport_fields
    def add_rexport_field(name, options = {})
      rexport_fields[name.to_s] = DataField.new(name, options)
    end

    # Removes files from rexport_fields
    # useful to remove content columns you don't want included in exports
    def remove_rexport_fields(*fields)
      fields.flatten.each { |field| rexport_fields.delete(field.to_s) }
    end

    # Adds associated methods to rexport_fields
    #   :associations - an association or arrary of associations
    #   :methods - a method or array of methods
    #   :filter - if true will send type: :association to add_report_field
    def add_association_methods(options = {})
      options.stringify_keys!
      options.assert_valid_keys(%w[associations methods filter])

      add_rexport_fields_for(
        associations: [options["associations"]].flatten,
        methods:      [options["methods"] || "name"].flatten,
        type:         (options["filter"] ? :association : nil)
      )
    end

    # Returns an array of export methods corresponding with field_names
    def get_rexport_methods(*field_names)
      field_names.flatten.map do |f|
        components = f.to_s.split(".")
        field_name = components.pop
        components.push(get_rexport_model(components).get_rexport_method(field_name)) * "."
      rescue NoMethodError
        "undefined_rexport_field"
      end
    end

    protected

    # Returns a rexport_model for the associated class by following the chain of associations
    def get_rexport_model(associations)
      associations.empty? ? self : rexport_models[associations.dup]
    end

    # Memoize rexport_models to avoid initializing rexport_fields multiple times
    def rexport_models
      @rexport_models ||= Hash.new do |hash, key|
        hash[key] = self.class.new(klass.get_klass_from_associations(key))
      end
    end

    # Returns the export method for a given field_name
    def get_rexport_method(field_name)
      rexport_fields[field_name]&.method || raise(NoMethodError)
    end

    private

    def all_objects_from(association)
      klass.reflect_on_association(association.to_sym).klass.all
    end

    def add_rexport_fields_for(associations:, methods:, type:)
      associations.each do |association|
        methods.each do |method|
          add_rexport_field("#{association}_#{method}", method: "#{association}.#{method}", type:)
        end
      end
    end

    def foreign_key_for(association_name)
      klass.reflect_on_association(association_name).foreign_key if association_name.present?
    end

    def initialize_rexport_fields
      klass.content_columns.each { |field| add_rexport_field(field.name, type: field.type) }
      klass.try(:initialize_local_rexport_fields, self)
    end
  end
end
