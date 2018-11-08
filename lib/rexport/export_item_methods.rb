module Rexport #:nodoc:
  module ExportItemMethods
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        include InstanceMethods

        acts_as_list scope: :export
        belongs_to :export
        before_validation :replace_blank_name_with_rexport_field
        validates_presence_of :name, :rexport_field
        scope :ordered, -> { order :position }
      end
    end

    module ClassMethods
      def resort(export_item_ids)
        export_item_ids.each_index do |index|
          position = index + 1
          export_item = find(export_item_ids[index].gsub(/[^0-9]/,''))
          export_item.update_attribute(:position, position) if export_item.position != position
        end
      end
    end

    module InstanceMethods
      def attributes_for_copy
        attributes.slice('position', 'name', 'rexport_field')
      end

      #######
      private
      #######

      def replace_blank_name_with_rexport_field
        return unless name.blank?
        self.name = if rexport_field.include?('.')
          rexport_field.split('.').values_at(-2..-1).map {|v| v.titleize}.join(' - ')
        else
          rexport_field.titleize
        end
      end
    end
  end
end
