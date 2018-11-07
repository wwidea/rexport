module Rexport #:nodoc:
  module ExportFilterMethods
    extend ActiveSupport::Concern

    included do
      belongs_to :export
      validates_presence_of :filter_field
    end

    def display_value
      return value unless filter_field[/_id$/]
      association = find_association
      return 'UNDEFINED ASSOCIATION' unless association
      begin
        object = association.klass.find(value)
        return object.respond_to?(:name) ? object.name : object.to_s
      rescue ActiveRecord::RecordNotFound
        return 'ASSOCIATED OBJECT NOT FOUND'
      end
    end

    def attributes_for_copy
      attributes.slice('filter_field', 'value')
    end

    private

    def find_association
      path = filter_field.split('.')
      foreign_key = path.pop
      export.get_klass_from_path(path).reflect_on_all_associations(:belongs_to).detect do |association|
        association.foreign_key == foreign_key
      end
    end
  end
end
