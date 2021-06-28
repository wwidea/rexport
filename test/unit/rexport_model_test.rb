require 'test_helper'

class RexportModel < ActiveSupport::TestCase
  test 'should initialize rexport_fields' do
    assert_equal(
      %w(active bad_method created_at foo_method grade ilp_status_name status_name updated_at),
      rexport_model.rexport_fields.keys.sort
    )
  end

  test 'should initialize data atributes' do
    assert_equal 'grade',   rexport_model.rexport_fields[:grade].method
    assert_equal :integer,  rexport_model.rexport_fields[:grade].type
  end

  test 'should initialize method' do
    assert_equal 'foo', rexport_model.rexport_fields[:foo_method].method
    assert_nil rexport_model.rexport_fields[:foo_method].type
  end

  test 'should add single association method to rexport_fields' do
    assert_fields_length do |rexport|
      rexport.add_association_methods(associations: 'test_association')
      assert_equal 'test_association_name', rexport.rexport_fields[:test_association_name].name
      assert_equal 'test_association.name', rexport.rexport_fields[:test_association_name].method
    end
  end

  test 'should add name methods for multiple associations' do
    assert_fields_length(change: 3) do |rexport|
      rexport.add_association_methods(associations: %w(a b c))
    end
  end

  test 'should add multiple methods for multiple associations' do
    assert_fields_length(change: 9) do |rexport|
      rexport.add_association_methods(associations: %w(a1 a2 a3), methods: %w(m1 m2 m3))
    end
  end

  test 'should remove single rexport field' do
    rexport_model.tap do |rexport|
      assert      rexport.rexport_fields[:grade]
      assert      rexport.remove_rexport_fields(:grade)
      assert_nil  rexport.rexport_fields[:grade]
    end
  end

  test 'should remove multiple rexport fields' do
    fields = %w(grade status_name foo_method)

    rexport_model.tap do |rexport|
      fields.each { |field| assert(rexport.rexport_fields[field]) }
      assert rexport.remove_rexport_fields(fields)
      fields.each { |field| assert_nil(rexport.rexport_fields[field]) }
    end
  end

  test 'should get rexport methods' do
    assert_equal(
      ['student.family.foo',
        'student.name',
        'undefined_rexport_field',
        'undefined_rexport_field',
        'status.name',
        'grade'
      ],
      rexport_model.get_rexport_methods(
        'student.family.foo_method',
        'student.name',
        'student.bad_method',
        'bad_association.test',
        'status_name',
        'grade'
      )
    )
  end

  test 'should return default foreign_key' do
    assert_equal 'status_id', rexport_model.filter_column(data_field('status_name'))
  end

  test 'should return custom foreign_key' do
    assert_equal 'ilp_status_id', rexport_model.filter_column(data_field('ilp_status_name'))
  end

  test 'should call rexport_fields_array' do
    assert_equal(
      %w(active bad_method created_at foo_method grade ilp_status_name status_name updated_at),
      rexport_model.rexport_fields_array.map(&:name)
    )
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
    rexport_model.rexport_fields[name]
  end

  def assert_fields_length(rexport: rexport_model, change: 1, &block)
    assert_difference('rexport.rexport_fields.length', change) do
      block.call(rexport)
    end
  end
end
