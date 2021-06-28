require 'test_helper'

class ExportMethodsTest < ActiveSupport::TestCase
  test 'should return models' do
    assert Export.models
  end

  test 'should return full name' do
    assert_equal 'Enrollments - Enrollment Export', build(:export).full_name
  end

  test 'should return header' do
    assert_equal ['Family Name', 'Grade', 'Status', 'Bogus Item'], create(:export).header
  end

  test 'should return rexport_fields' do
    assert_equal(
      %w(student.family.name grade status_name bogus_field),
      build(:export).send(:rexport_fields)
    )
  end

  test 'should return rexport_methods' do
    assert_equal(
      %w(student.family.name grade status.name undefined_rexport_field),
      create(:export).send(:rexport_methods)
    )
  end

  test 'should return records' do
    create(:enrollment)
    assert_equal(
      ['The Sample Family', '1', 'active', 'UNDEFINED EXPORT FIELD'],
      create(:export).records.first
    )
  end

  test 'should return records that match filters' do
    create(:enrollment)
    create(:second_grade_enrollment)
    assert_equal 2, Enrollment.count
    assert_equal [['1', 'active']], create(:filtered_export).records
  end

  test 'should call get_records' do
    export = build(:export)
    export.expects(:get_records).with(Rexport::SAMPLE_SIZE).returns(true)
    assert export.sample_records
  end

  test 'should return to_s with no records' do
    assert_equal "Family Name|Grade|Status|Bogus Item\n", create(:export).to_s
  end

  test 'should return to_s with record' do
    create(:enrollment)
    assert_equal(
      "Family Name|Grade|Status|Bogus Item\nThe Sample Family|1|active|UNDEFINED EXPORT FIELD\n",
      create(:export).to_s
    )
  end

  test 'should return to_csv with no records' do
    assert_equal "Family Name,Grade,Status,Bogus Item\n", create(:export).to_csv
  end

  test 'should return to_csv with record' do
    FactoryBot.create(:enrollment)
    assert_equal(
      "Family Name,Grade,Status,Bogus Item\nThe Sample Family,1,active,UNDEFINED EXPORT FIELD\n",
      create(:export).to_csv
    )
  end

  test 'should return to_csv with passed objects' do
    assert_equal(
      "Family Name,Grade,Status,Bogus Item\n\"\",99,\"\",UNDEFINED EXPORT FIELD\n",
      create(:export).to_csv([Enrollment.new(grade: 99)])
    )
  end

  test 'should return build_conditions' do
    assert_equal(
      {'statuses.name' => 'active', 'enrollments.grade' => '1'},
      create(:filtered_export).send(:build_conditions)
    )
  end

  test 'should return build_include' do
    assert_equal [{student: [:family]}, :status], create(:export).send(:build_include)
  end

  test 'should return rexport_models' do
    export = create(:export)
    assert_equal(
      %w(Enrollment Family SelfReferentialCheck Student),
      export.rexport_models.map(&:name).sort
    )
    assert_equal(
      ['', 'self_referential_check', 'student', 'student.family'],
      export.rexport_models.map(&:path).map(&:to_s).sort
    )
  end

  test 'should return true for has_rexport_field?' do
    assert build(:export).has_rexport_field?('student.family.name')
  end

  test 'should return false for has_rexport_field?' do
    refute build(:export).has_rexport_field?('student.family.number')
  end

  test 'should save export_items from a hash' do
    assert_equal %w(a b c), rexport_fields_for(create_export(fields: {a: 1, b: 1, c: 1}))
  end

  test 'should save export_items from an array' do
    assert_equal %w(a b c), rexport_fields_for(create_export(fields: %w(a b c)))
  end

  test 'should add export_item to exising export on update' do
    export = create_export(fields: %w(a c))
    assert_difference 'ExportItem.count' do
      export.update_attribute(:rexport_fields, %w(a b c))
    end
    assert_equal %w(a b c), rexport_fields_for(export)
  end

  test 'should delete export_item that is not in rexport_fields on update' do
    export = create_export(fields: %w(a b c))
    assert_difference 'ExportItem.count', -1 do
      export.update_attribute(:rexport_fields, %w(a c))
    end
    assert_equal %w(a c), rexport_fields_for(export)
  end

  test 'should re-order export_items when passed an array of export_fields on update' do
    export = create_export(fields: %w(a b c))
    export.update_attribute(:rexport_fields, %w(c b a))
    assert_equal %w(c b a), rexport_fields_for(export)
  end

  test 'should not re-order export_items when passed a hash of export_fields on update' do
    export = create_export(fields: %w(a b c))
    export.update_attribute(:rexport_fields, {c: 1, b: 1, a: 1})
    assert_equal %w(a b c), rexport_fields_for(export)
  end

  test 'should not modify export_items on update when no export_fields are passed' do
    export = create_export(fields: %w(a b c))
    assert_no_difference 'ExportItem.count' do
      export.update_attribute(:name, 'New Name')
    end
    assert_equal %w(a b c), rexport_fields_for(export)
  end

  test 'should create export with an export_filter' do
    assert_difference 'ExportFilter.count' do
      create_export(filters: {status_id: 1})
    end
  end

  test 'should add an export_filter to an existing export' do
    export = create_export
    assert_difference 'ExportFilter.count' do
      export.update_attribute(:export_filter_attributes, {status_id: 1})
    end
  end

  test 'should delete an export_filter from an export' do
    export = create_export(filters: {status_id: 1})
    assert_difference 'ExportFilter.count', -1 do
      export.update_attribute(:export_filter_attributes, {status_id: ''})
    end
  end

  test 'should return filter_value for filter_field' do
    assert_equal 'active', create(:filtered_export).filter_value('status.name')
  end

  test 'should return nil for filter_value when no matching export_filters' do
    assert_nil create(:filtered_export).filter_value('does_not_exist')
  end

  test 'should create copy with unique name' do
    assert_equal 'Enrollment Export Copy',      create(:export).copy.name
    assert_equal 'Enrollment Export Copy [1]',  create(:export).copy.name
    assert_equal 'Enrollment Export Copy [2]',  create(:export).copy.name
  end

  test 'should copy export with export_items' do
    export = create(:export)
    assert_difference 'ExportItem.count', export.export_items.count do
      export.copy.export_items.count
    end
  end

  test 'should copy export with export_filters' do
    export = create(:filtered_export)
    assert_difference 'ExportFilter.count', export.export_filters.count do
      export.copy
    end
  end

  private

  def create_export(fields: {}, filters: {})
    Export.create(
      name:                     'Test',
      model_class_name:         'Enrollment',
      rexport_fields:           fields,
      export_filter_attributes: filters
    )
  end

  def rexport_fields_for(export)
    export.export_items.ordered.map(&:rexport_field)
  end
end
