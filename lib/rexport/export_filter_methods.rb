module Rexport #:nodoc:
  module ExportFilterMethods
    def self.included(base)
      base.class_eval do
        include InstanceMethods
        
        belongs_to :export
        validates_presence_of :field
      end
    end
    
    module InstanceMethods
      def display_value
        return value unless field[/_id$/]
        path = field.split('.')
        primary_key_name = path.pop
        association = export.get_klass_from_path(path).reflect_on_all_associations(:belongs_to).detect do |association|
          association.primary_key_name == primary_key_name
        end
        return 'UNDEFINED ASSOCIATION' unless association
        begin
          object = association.klass.find(value)
          return object.respond_to?(:name) ? object.name : object.to_s
        rescue ActiveRecord::RecordNotFound
          return 'ASSOCIATED OBJECT NOT FOUND'
        end
      end
    end
  end
end