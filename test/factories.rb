module Rexport
  module Factories

    FactoryBot.define do

      factory :status do
        name { 'active' }
      end

      factory :family do
        name { 'The Sample Family' }
      end

      factory :student do
        family        { |family| family.association(:family) }
        name          { 'Sammy Sample' }
        date_of_birth { Date.parse('2008-12-08') }
      end

      factory :enrollment do
        status      { |status|  status.association(:status) }
        student     { |student| student.association(:student) }
        grade       { 1 }
        updated_at  { Time.now }
      end

      factory :second_grade_enrollment, class: 'Enrollment' do
        status  { |status| status.association(:status) }
        grade   { 2 }
      end

      factory :export do
        name              { 'Enrollment Export' }
        model_class_name  { 'Enrollment' }
        export_items do |items|
          %w(family_name_export_item grade_export_item status_name_export_item bogus_export_item).map do |item|
            items.association(item)
          end
        end
      end

      factory :filtered_export, class: 'Export' do
        name              { 'Filtered Enrollment Export' }
        model_class_name  { 'Enrollment' }
        export_items do |items|
          %w(grade_export_item status_name_export_item).map do |item|
            items.association(item)
          end
        end
        export_filters do |filters|
          %w(grade_filter status_filter).map do |filter|
            filters.association(filter)
          end
        end
      end

      factory :family_name_export_item, class: 'ExportItem' do
        position       { 1 }
        name           { 'Family Name' }
        rexport_field  { 'student.family.name' }
      end

      factory :grade_export_item, class: 'ExportItem' do
        position       { 2 }
        rexport_field  { 'grade' }
      end

      factory :status_name_export_item, class: 'ExportItem' do
        position       { 3 }
        name           { 'Status' }
        rexport_field  { 'status_name' }
      end

      factory :bogus_export_item, class: 'ExportItem' do
        position       { 4 }
        name           { 'Bogus Item' }
        rexport_field  { 'bogus_field' }
      end

      factory :grade_filter, class: 'ExportFilter' do
        filter_field   { 'grade' }
        value          { '1' }
      end

      factory :status_filter, class: 'ExportFilter' do
        filter_field   { 'status.name' }
        value          { 'active' }
      end
    end
  end
end
