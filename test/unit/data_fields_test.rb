require 'test_helper'

class DataFieldsTest < ActiveSupport::TestCase

  class RexportClassMethodsTest < DataFieldsTest
    test 'should initialize local rexport fields' do
      assert_kind_of(Hash, Enrollment.rexport_fields)
      assert_equal(%w(active bad_method created_at foo_method grade ilp_status_name status_name updated_at), Enrollment.rexport_fields.keys.sort)
      assert_equal('grade', Enrollment.rexport_fields[:grade].method)
      assert_equal('foo', Enrollment.rexport_fields[:foo_method].method)
      assert_equal(:boolean, Enrollment.rexport_fields[:active].type)
      assert_equal(:integer, Enrollment.rexport_fields[:grade].type)
    end

    test 'should return sorted data fields array' do
      assert_equal(
        %w(active bad_method created_at foo_method grade ilp_status_name status_name updated_at),
        Enrollment.rexport_fields_array.map(&:name)
      )
    end

    test 'should add single association method to rexport_fields' do
      assert_difference('Enrollment.rexport_fields.length') do
        Enrollment.add_association_methods(associations: 'test_association')
      end
      assert_equal 'test_association_name', Enrollment.rexport_fields[:test_association_name].name
      assert_equal 'test_association.name', Enrollment.rexport_fields[:test_association_name].method
    end

    test 'should add name methods for multiple associations' do
      assert_difference('Enrollment.rexport_fields.length', 3) do
        Enrollment.add_association_methods(associations: %w(a b c))
      end
    end

    test 'should add multiple methods for multiple associations' do
      assert_difference('Enrollment.rexport_fields.length', 9) do
        Enrollment.add_association_methods(associations: %w(a1 a2 a3), methods: %w(m1 m2 m3))
      end
    end

    test 'should get rexport methods' do
      assert_equal %w(grade),                   Enrollment.get_rexport_methods(:grade)
      assert_equal %w(status.name),             Enrollment.get_rexport_methods(:status_name)
      assert_equal %w(undefined_rexport_field), Enrollment.get_rexport_methods('bad_association.test')
      assert_equal %w(undefined_rexport_field), Enrollment.get_rexport_methods('student.bad_method')
      assert_equal %w(student.name),            Enrollment.get_rexport_methods('student.name')
      assert_equal %w(student.family.foo),      Enrollment.get_rexport_methods('student.family.foo_method')
      assert_equal(
        ['student.family.foo', 'student.name', 'undefined_rexport_field', 'undefined_rexport_field', 'status.name', 'grade'],
        Enrollment.get_rexport_methods('student.family.foo_method', 'student.name', 'student.bad_method', 'bad_association.test', 'status_name', 'grade')
      )
    end

    test 'should remove single rexport field' do
      assert      Enrollment.rexport_fields[:grade]
      assert      Enrollment.remove_rexport_fields(:grade)
      assert_nil  Enrollment.rexport_fields[:grade]
    end

    test 'should remove multiple rexport fields' do
      fields = %w(grade status_name foo_method)
      fields.each { |field| assert(Enrollment.rexport_fields[field]) }
      assert Enrollment.remove_rexport_fields(fields)
      fields.each { |field| assert_nil(Enrollment.rexport_fields[field]) }
    end

    test 'should get klass from assocations' do
      assert_equal Family, Enrollment.get_klass_from_associations('student', 'family')
    end

    test 'should rasie no method error for missing associations' do
      assert_raise NoMethodError do
        Enrollment.get_klass_from_associations('not_an_association')
      end
    end

    test 'reset column information with rexport reset' do
      assert Enrollment.rexport_fields
      assert Enrollment.instance_variable_get('@rexport_fields')
      Enrollment.reset_column_information
      assert_nil Enrollment.instance_variable_get('@rexport_fields')
    end
  end

  class RexportInstanceMethodsTest < DataFieldsTest
    test 'should export fields for record' do
      enrollment = FactoryBot.create(:enrollment)
      assert_equal %w(1), enrollment.export('grade')
      assert_equal %w(bar), enrollment.export('foo')
      assert_equal [''], enrollment.export('bad_method')
      assert_equal %w(1 bar) << Time.now.utc.strftime("%m/%d/%y"), enrollment.export('grade', 'foo', 'updated_at')
    end

    test 'should handle missing associations' do
      enrollment = Enrollment.new
      assert_equal [''], enrollment.export('status.name')
      assert_equal [''], enrollment.export('student.name')
    end

    test 'should handle undefined export' do
      enrollment = FactoryBot.create(:enrollment)
      assert_equal ['UNDEFINED EXPORT FIELD'], enrollment.export('undefined_rexport_field')
    end

    test 'should export associated fields' do
      enrollment = FactoryBot.create(:enrollment)
      assert_equal ['Sammy Sample'], enrollment.export('student.name')
      assert_equal ['The Sample Family'], enrollment.export('student.family.name')
      assert_equal %w(bar), enrollment.export('student.family.foo')
    end

    test 'should export field from non rexported model' do
      enrollment = FactoryBot.create(:enrollment)
      assert_equal ['active'], enrollment.export('status.name')
    end

    test 'should export local associated and non rexported fields' do
      enrollment = FactoryBot.create(:enrollment)
      assert_equal(
        ['The Sample Family', 'Sammy Sample', '1', 'bar', 'active'],
        enrollment.export('student.family.name', 'student.name', 'grade', 'student.family.foo', 'status.name')
      )
    end
  end
end
