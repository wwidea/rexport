require 'test_helper'

class RexportModel < ActiveSupport::TestCase
  def test_return_correct_foreign_key
    rexport_model = Rexport::RexportModel.new(Enrollment)

    data_field = Enrollment.rexport_fields['status_name']
    assert_equal('status_id', rexport_model.filter_column(data_field))

    data_field = Enrollment.rexport_fields['ilp_status_name']
    assert_equal('ilp_status_id', rexport_model.filter_column(data_field))
  end

  def test_should_call_rexport_fields_array
    rexport_model = Rexport::RexportModel.new(Enrollment)
    Enrollment.expects(:rexport_fields_array).returns(true)
    assert(rexport_model.rexport_fields_array)
  end

  def test_field_path
    rexport_model = Rexport::RexportModel.new(Enrollment, 'foo')
    assert_equal('foo.bar', rexport_model.field_path('bar'))
  end

  def test_collection_from_association
    rexport_model = Rexport::RexportModel.new(Enrollment)
    Status.expects(:all).returns(true)
    assert(rexport_model.collection_from_association('status'))
  end

  def test_should_return_class_name
    rexport_model = Rexport::RexportModel.new(Enrollment)
    assert_equal('Enrollment', rexport_model.name)
  end
end