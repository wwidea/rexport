module Rexport #:nodoc:
  
  # Stores the name and method of the export data item
  class DataField
    include Comparable
    attr_accessor :name, :method, :type
    
    def initialize(name, options = {})
      self.name = name.to_s
      self.method = options[:method].blank? ? self.name : options[:method].to_s
      self.type = options[:type]
    end
    
    def <=>(rf)
      self.name <=> rf.name
    end
  end
  
  module DataFields
    def self.included( base )
      base.extend( ClassMethods )
      base.class_eval do
        include InstanceMethods
        class << self
          alias_method_chain :reset_column_information, :rexport_reset
        end
      end
      base.valid_keys_for_belongs_to_association += [:rexport] unless base.valid_keys_for_belongs_to_association.include?(:rexport)
    end
    
    module ClassMethods
      # Returns hash of exportable data items
      def rexport_fields
        unless @rexport_fields
          @rexport_fields = HashWithIndifferentAccess.new
          initialize_rexport_fields
        end
        @rexport_fields
      end
      
      # Returns sorted array of rexport DataFields
      def rexport_fields_array
        rexport_fields.merge(dynamic_rexport_fields).values.sort
      end
    
      # Adds a data item to rexport_fields
      def add_rexport_field(name, options = {})
        rexport_fields[name.to_s] = DataField.new(name, options)
      end
      
      # Adds associated methods to rexport_fields
      #   :associations - an association or arrary of associations
      #   :methods - a method or array of methods
      #   :filter - if true will send :type => :association to add_report_field
      def add_association_methods(options = {})
        options.stringify_keys!
        options.assert_valid_keys(%w(associations methods filter))
        
        methods = options.reverse_merge('methods' => 'name')['methods']
        methods = [methods] if methods.kind_of?(String)
        
        associations = options['associations']
        associations = [associations] if associations.kind_of?(String)
            
        type = options['filter'] ? :association : nil
        
        associations.each do |association|
          methods.each do |method|
            add_rexport_field("#{association}_#{method}", :method => "#{association}.#{method}", :type => type)
          end
        end
      end
      
      # Removes files from rexport_fields
      # useful to remove content columns you don't want included in exports
      def remove_rexport_fields(*fields)
        fields.flatten.each {|field| rexport_fields.delete(field.to_s)}
      end
    
      # Returns an array of export methods corresponding with field_names
      def get_rexport_methods(*field_names)
        field_names.flatten.map do |f|
          begin
            components = f.to_s.split('.')
            field_name = components.pop
            components.push(get_klass_from_associations(components).get_rexport_method(field_name)) * '.'
          rescue NoMethodError
            'undefined_rexport_field'
          end
        end
      end
    
      # Returns the associated class by following the associations
      def get_klass_from_associations(*associations)
        associations.flatten!
        return self if associations.empty?
        reflect_on_association(associations.shift.to_sym).klass.get_klass_from_associations(associations)
      end
    
      # Returns the export method for a given field_name
      def get_rexport_method(field_name)
        raise NoMethodError unless rexport_fields[field_name] or dynamic_rexport_fields[field_name]
        if rexport_fields[field_name]
          rexport_fields[field_name].method
        else
          dynamic_rexport_fields[field_name].method
        end
      end
      
      def reset_column_information_with_rexport_reset
        reset_column_information_without_rexport_reset
        @rexport_fields = nil
      end
    
      private
    
      # Adds content columns to rexport_fields, includes callback initialize_local_rexport_fields
      # for client defined initialization
      def initialize_rexport_fields
        content_columns.each do |f|
          add_rexport_field(f.name, :type => f.type)
        end
        initialize_local_rexport_fields if respond_to?(:initialize_local_rexport_fields)
      end
      
      def dynamic_rexport_fields
        respond_to?(:initialize_dynamic_rexport_fields) ? initialize_dynamic_rexport_fields : {}
      end
    end
  
    module InstanceMethods
      # Return an array of formatted export for the passed methods
      def export(*methods)
        methods.flatten.map do |method|
          case value = (eval("self.#{method}", binding) rescue nil)
            when Date, Time
              value.strftime("%m/%d/%y")
            when TrueClass
              'Y'
            when FalseClass
              'N'
            else value.to_s
          end
        end
      end
        
      # Returns string indicating this field is undefined
      def undefined_rexport_field
        'UNDEFINED EXPORT FIELD'
      end
    end
  end
end
