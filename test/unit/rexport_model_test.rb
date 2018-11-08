require 'test_helper'

class RexportModel < ActiveSupport::TestCase
  test 'should return correct foreign_key' do
    rexport_model = Rexport::RexportModel.new(Enrollment)

    data_field = Enrollment.rexport_fields['status_name']
    assert_equal 'status_id', rexport_model.filter_column(data_field)

    data_field = Enrollment.rexport_fields['ilp_status_name']
    assert_equal 'ilp_status_id', rexport_model.filter_column(data_field)
  end

  test 'should call rexport_fields_array' do
    rexport_model = Rexport::RexportModel.new(Enrollment)
    Enrollment.expects(:rexport_fields_array).returns(true)
    assert rexport_model.rexport_fields_array
  end

  test 'should return field_path' do
    rexport_model = Rexport::RexportModel.new(Enrollment, 'foo')
    assert_equal 'foo.bar', rexport_model.field_path('bar')
  end

  test 'should return collection_from_association' do
    rexport_model = Rexport::RexportModel.new(Enrollment)
    Status.expects(:all).returns(true)
    assert rexport_model.collection_from_association('status')
  end

  test 'should return class name' do
    rexport_model = Rexport::RexportModel.new(Enrollment)
    assert_equal 'Enrollment', rexport_model.name
  end
end
