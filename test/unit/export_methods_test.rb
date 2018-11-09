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
end
