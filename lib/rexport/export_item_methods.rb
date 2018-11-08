module Rexport #:nodoc:
  module ExportItemMethods
    extend ActiveSupport::Concern

    included do
      acts_as_list scope: :export

      belongs_to :export

      before_validation :replace_blank_name_with_rexport_field
      validates_presence_of :name, :rexport_field

      scope :ordered, -> { order :position }
    end

    module ClassMethods
      def resort(export_item_ids)
        transaction do
          export_item_ids.each_with_index do |id, index|
            find(id.gsub(/[^0-9]/, '')).update_attribute(:position, index + 1)
          end
        end
      end
    end

    def attributes_for_copy
      attributes.slice('position', 'name', 'rexport_field')
    end

    private

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
