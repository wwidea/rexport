require 'test_helper'

class ExportMethodsTest < ActiveSupport::TestCase
  def test_should_return_header
    export = FactoryBot.create(:export)
    assert_equal(['Family Name', 'Grade', 'Status', 'Bogus Item'], export.header)
  end

  def test_should_return_rexport_fields
    export = FactoryBot.create(:export)
    assert_equal(%w(student.family.name grade status_name bogus_field), export.send(:rexport_fields))
  end

  def test_should_return_rexport_methods
    export = FactoryBot.create(:export)
    assert_equal(%w(student.family.name grade status.name undefined_rexport_field), export.send(:rexport_methods))
  end

  def test_records
    export = FactoryBot.create(:export)
    FactoryBot.create(:enrollment)
    assert_equal(['The Sample Family', '1', 'active', 'UNDEFINED EXPORT FIELD'], export.records.first)
  end

  def test_records_with_filters
    export = FactoryBot.create(:export)
    filtered_export = FactoryBot.create(:export)
    FactoryBot.create(:enrollment)
    FactoryBot.create(:second_grade_enrollment)
    assert_equal(2, Enrollment.count)
    assert_equal(2, export.records.length)
    assert_equal(['The Sample Family', '1', 'active', 'UNDEFINED EXPORT FIELD'], filtered_export.records.first)
  end

  def test_sample_records
    export = FactoryBot.create(:export)
    export.expects(:get_records).with(Rexport::SAMPLE_SIZE).returns(true)
    assert(export.sample_records)
  end

  def test_to_s_with_no_records
    export = FactoryBot.create(:export)
    assert_equal("Family Name|Grade|Status|Bogus Item\n", export.to_s)
  end

  def test_to_s_with_record
    export = FactoryBot.create(:export)
    FactoryBot.create(:enrollment)
    assert_equal("Family Name|Grade|Status|Bogus Item\nThe Sample Family|1|active|UNDEFINED EXPORT FIELD\n", export.to_s)
  end

  def test_to_csv_with_no_records
    export = FactoryBot.create(:export)
    assert_equal("Family Name,Grade,Status,Bogus Item\n", export.to_csv)
  end

  def test_to_csv_with_record
    export = FactoryBot.create(:export)
    FactoryBot.create(:enrollment)
    assert_equal("Family Name,Grade,Status,Bogus Item\nThe Sample Family,1,active,UNDEFINED EXPORT FIELD\n", export.to_csv)
  end

  def test_to_csv_with_passed_objects
    export = FactoryBot.create(:export)
    assert_equal("Family Name,Grade,Status,Bogus Item\n\"\",99,\"\",UNDEFINED EXPORT FIELD\n", export.to_csv([Enrollment.new(:grade => 99)]))
  end

  def test_build_conditions
    export = FactoryBot.create(:filtered_export)
    assert_equal({'statuses.name' => 'active', 'enrollments.grade' => '1'}, export.send(:build_conditions))
  end

  def test_build_include
    export = FactoryBot.create(:export)
    assert_equal([{:student=>[:family]}, :status], export.send(:build_include))
  end

  def test_should_return_rexport_models
    export = FactoryBot.create(:export)
    assert_equal(%w(Enrollment Family SelfReferentialCheck Student), export.rexport_models.map {|m| m.klass.to_s}.sort)
    assert_equal(['', 'self_referential_check', 'student', 'student.family'], export.rexport_models.map {|m| m.path.to_s}.sort)
  end

  def test_should_create_copy_with_unique_name
    assert_equal 'Enrollment Export Copy', FactoryBot.create(:export).copy.name
    assert_equal 'Enrollment Export Copy [1]', FactoryBot.create(:export).copy.name
    assert_equal 'Enrollment Export Copy [2]', FactoryBot.create(:export).copy.name
  end

  def test_should_copy_export_with_export_items
    assert_equal FactoryBot.create(:export).export_items.count, FactoryBot.create(:export).copy.export_items.count
  end

  def test_should_copy_export_with_export_filters
    assert_equal FactoryBot.create(:filtered_export).export_filters.count, FactoryBot.create(:filtered_export).copy.export_filters.count
  end
end
