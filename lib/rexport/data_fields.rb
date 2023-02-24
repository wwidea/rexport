# frozen_string_literal: true

module Rexport # :nodoc:
  module DataFields
    extend ActiveSupport::Concern

    module ClassMethods
      # Returns the associated class by following the chain of associations
      def get_klass_from_associations(*associations)
        associations.flatten!
        return self if associations.empty?

        reflect_on_association(associations.shift.to_sym).klass.get_klass_from_associations(associations)
      end
    end

    # Return an array of formatted export values for the passed methods
    def export(*methods)
      methods.flatten.map do |method|
        case value = (eval("self.#{method}", binding) rescue nil)
          when Date, Time
            value.strftime("%m/%d/%y")
          when TrueClass
            "Y"
          when FalseClass
            "N"
          else value.to_s
        end
      end
    end

    # Returns string indicating this field is undefined
    def undefined_rexport_field
      "UNDEFINED EXPORT FIELD"
    end
  end
end
