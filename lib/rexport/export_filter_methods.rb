module Rexport #:nodoc:
  module ExportFilterMethods
    extend ActiveSupport::Concern

    included do
      belongs_to :export
      validates_presence_of :filter_field
    end

    def display_value
      filter_on_associated_object? ? associated_object_value : value
    end

    def attributes_for_copy
      attributes.slice('filter_field', 'value')
    end

    private

    def associated_object_value
      return 'UNDEFINED ASSOCIATION' unless filter_association
      begin
        object = filter_association.klass.find(value)
        return object.respond_to?(:name) ? object.name : object.to_s
      rescue ActiveRecord::RecordNotFound
        return 'ASSOCIATED OBJECT NOT FOUND'
      end
    end

    def filter_association
      @filter_on_assocation ||= find_filter_association
    end

    def find_filter_association
      belongs_to_associations.detect do |association|
        association.foreign_key == filter_foreign_key
      end
    end

    def belongs_to_associations
      export.get_klass_from_path(filter_path).reflect_on_all_associations(:belongs_to)
    end

    def filter_path
      filter_field.split('.')[0..-2]
    end

    def filter_foreign_key
      filter_field.split('.').last
    end

    def filter_on_associated_object?
      filter_field[/_id$/]
    end
  end
end
