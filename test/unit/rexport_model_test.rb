require 'test_helper'

class RexportModel < ActiveSupport::TestCase
  test 'should return default foreign_key' do
    assert_equal 'status_id', rexport_model.filter_column(data_field('status_name'))
  end

  test 'should return custom foreign_key' do
    assert_equal 'ilp_status_id', rexport_model.filter_column(data_field('ilp_status_name'))
  end

  test 'should call rexport_fields_array' do
    Enrollment.expects(:rexport_fields_array).returns(true)
    assert rexport_model.rexport_fields_array
  end

  test 'should return field_path' do
    assert_equal 'foo.bar', rexport_model(path: 'foo').field_path('bar')
  end

  test 'should return collection_from_association' do
    Status.expects(:all).returns(true)
    assert rexport_model.collection_from_association('status')
  end

  test 'should return class name' do
    assert_equal 'Enrollment', rexport_model.name
  end

  private

  def rexport_model(path: nil)
    Rexport::RexportModel.new(Enrollment, path: path)
  end

  def data_field(name)
    Enrollment.rexport_fields[name]
  end
end
