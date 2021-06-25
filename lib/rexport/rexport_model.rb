module Rexport #:nodoc:
  class RexportModel
    attr_accessor :klass, :path

    def initialize(klass, path: nil)
      self.klass = klass
      self.path = path.to_s unless path.blank?
    end

    def rexport_fields_array
      klass.rexport_fields_array
    end

    def field_path(field_name)
      [path, field_name].compact * '.'
    end

    def collection_from_association(association)
      return klass.send("find_#{association}_for_rexport") if klass.respond_to?("find_#{association}_for_rexport")
      klass.reflect_on_association(association.to_sym).klass.all
    end

    def filter_column(field)
      return field.method unless field.method.include?('.')
      association = field.method.split('.').first
      klass.reflect_on_association(association.to_sym).foreign_key
    end

    def name
      klass.name
    end
  end
end
