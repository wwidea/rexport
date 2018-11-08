require 'test_helper'

class ExportMethodsTest < ActiveSupport::TestCase
  test 'should return models' do
    assert Export.models
  end

  test 'should return full name' do
    assert_equal 'Enrollments - Enrollment Export', FactoryBot.create(:export).full_name
  end

  test 'should return header' do
    assert_equal ['Family Name', 'Grade', 'Status', 'Bogus Item'], FactoryBot.create(:export).header
  end

  test 'should return rexport_fields' do
    export = FactoryBot.create(:export)
    assert_equal %w(student.family.name grade status_name bogus_field), export.send(:rexport_fields)
  end

  test 'should return rexport_methods' do
    export = FactoryBot.create(:export)
    assert_equal %w(student.family.name grade status.name undefined_rexport_field), export.send(:rexport_methods)
  end

  test 'should return records' do
    export = FactoryBot.create(:export)
    FactoryBot.create(:enrollment)
    assert_equal ['The Sample Family', '1', 'active', 'UNDEFINED EXPORT FIELD'], export.records.first
  end

  test 'records with filters' do
    export = FactoryBot.create(:export)
    filtered_export = FactoryBot.create(:export)
    FactoryBot.create(:enrollment)
    FactoryBot.create(:second_grade_enrollment)
    assert_equal 2, Enrollment.count
    assert_equal 2, export.records.length
    assert_equal ['The Sample Family', '1', 'active', 'UNDEFINED EXPORT FIELD'], filtered_export.records.first
  end

  test 'should call get_records' do
    export = FactoryBot.create(:export)
    export.expects(:get_records).with(Rexport::SAMPLE_SIZE).returns(true)
    assert export.sample_records
  end

  test 'should return to_s with no records' do
    export = FactoryBot.create(:export)
    assert_equal "Family Name|Grade|Status|Bogus Item\n", export.to_s
  end

  test 'should return to_s with record' do
    export = FactoryBot.create(:export)
    FactoryBot.create(:enrollment)
    assert_equal "Family Name|Grade|Status|Bogus Item\nThe Sample Family|1|active|UNDEFINED EXPORT FIELD\n", export.to_s
  end

  test 'should return to_csv with no records' do
    export = FactoryBot.create(:export)
    assert_equal "Family Name,Grade,Status,Bogus Item\n", export.to_csv
  end

  test 'should return to_csv with record' do
    export = FactoryBot.create(:export)
    FactoryBot.create(:enrollment)
    assert_equal "Family Name,Grade,Status,Bogus Item\nThe Sample Family,1,active,UNDEFINED EXPORT FIELD\n", export.to_csv
  end

  test 'should return to_csv with passed objects' do
    export = FactoryBot.create(:export)
    assert_equal "Family Name,Grade,Status,Bogus Item\n\"\",99,\"\",UNDEFINED EXPORT FIELD\n", export.to_csv([Enrollment.new(grade: 99)])
  end

  test 'should return build_conditions' do
    export = FactoryBot.create(:filtered_export)
    assert_equal({'statuses.name' => 'active', 'enrollments.grade' => '1'}, export.send(:build_conditions))
  end

  test 'should return build_include' do
    export = FactoryBot.create(:export)
    assert_equal [{student: [:family]}, :status], export.send(:build_include)
  end

  test 'should return rexport_models' do
    export = FactoryBot.create(:export)
    assert_equal %w(Enrollment Family SelfReferentialCheck Student), export.rexport_models.map {|m| m.klass.to_s}.sort
    assert_equal ['', 'self_referential_check', 'student', 'student.family'], export.rexport_models.map {|m| m.path.to_s}.sort
  end

  test 'should create copy with unique name' do
    assert_equal 'Enrollment Export Copy',      FactoryBot.create(:export).copy.name
    assert_equal 'Enrollment Export Copy [1]',  FactoryBot.create(:export).copy.name
    assert_equal 'Enrollment Export Copy [2]',  FactoryBot.create(:export).copy.name
  end

  test 'should copy export with export_items' do
    assert_equal FactoryBot.create(:export).export_items.count, FactoryBot.create(:export).copy.export_items.count
  end

  test 'should copy export with export_filters' do
    assert_equal FactoryBot.create(:filtered_export).export_filters.count, FactoryBot.create(:filtered_export).copy.export_filters.count
  end
end
