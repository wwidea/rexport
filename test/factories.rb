module Rexport
  module Factories
    Factory.define :status do |s|
      s.name 'active'
    end

    Factory.define :family do |f|
      f.name 'The Sample Family'
    end

    Factory.define :student do |s|
      s.family        {|f| f.association(:family)}
      s.name          'Sammy Sample'
      s.date_of_birth Date.parse('2008-12-08')
    end

    Factory.define :enrollment do |e|
      e.status {|status| status.association(:status)}
      e.student {|s| s.association(:student)}
      e.grade   1
    end

    Factory.define :second_grade_enrollment, :class => 'Enrollment' do |e|
      e.status {|status| status.association(:status)}
      e.grade 2
    end

    Factory.define :export do |e|
      e.name 'Enrollment Export'
      e.model_name 'Enrollment'
      e.built_in_key 'enrollment_export'
      e.export_items do |items|
        %w(family_name_export_item grade_export_item status_name_export_item bogus_export_item).map do |item|
          items.association(item)
        end
      end
    end

    Factory.define :filtered_export, :class => 'Export' do |e|
      e.name 'Filtered Enrollment Export'
      e.model_name 'Enrollment'
      e.export_filters do |filters|
        %w(grade_filter status_filter).map do |filter|
          filters.association(filter)
        end
      end
    end

    Factory.define :family_name_export_item, :class => 'ExportItem' do |ei|
      ei.position       1
      ei.name           'Family Name'
      ei.rexport_field  'student.family.name'
    end

    Factory.define :grade_export_item, :class => 'ExportItem' do |ei|
      ei.position       2
      ei.name           'Grade'
      ei.rexport_field  'grade'
    end

    Factory.define :status_name_export_item, :class => 'ExportItem' do |ei|
      ei.position       3
      ei.name           'Status'
      ei.rexport_field  'status_name'
    end

    Factory.define :bogus_export_item, :class => 'ExportItem' do |ei|
      ei.position       4
      ei.name           'Bogus Item'
      ei.rexport_field  'bogus_field'
    end

    Factory.define :grade_filter, :class => 'ExportFilter' do |ef|
      ef.filter_field   'grade'
      ef.value          '1'
    end

    Factory.define :status_filter, :class => 'ExportFilter' do |ef|
      ef.filter_field   'status.name'
      ef.value          'active'
    end
  end
end