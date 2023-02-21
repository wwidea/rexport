# frozen_string_literal: true

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
            find(id.gsub(/[^0-9]/, "")).update_attribute(:position, index + 1)
          end
        end
      end
    end

    def attributes_for_copy
      attributes.slice("position", "name", "rexport_field")
    end

    private

    def replace_blank_name_with_rexport_field
      self.name = generate_name_from_rexport_field if name.blank?
    end

    def generate_name_from_rexport_field
      rexport_field.split(".").last(2).map(&:titleize).join(" - ")
    end
  end
end
