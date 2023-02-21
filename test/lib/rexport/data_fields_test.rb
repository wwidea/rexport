# frozen_string_literal: true

require "test_helper"

class DataFieldsTest < ActiveSupport::TestCase

  class RexportClassMethodsTest < DataFieldsTest
    test "should get klass from assocations" do
      assert_equal Family, Enrollment.get_klass_from_associations("student", "family")
    end

    test "should raise no method error for missing associations" do
      assert_raise NoMethodError do
        Enrollment.get_klass_from_associations("not_an_association")
      end
    end
  end

  class RexportInstanceMethodsTest < DataFieldsTest
    test "should exoport value of data attribute" do
      assert_equal %w(1), build(:enrollment).export("grade")
    end

    test "should export value returned from method" do
      assert_equal %w(bar), build(:enrollment).export("foo")
    end

    test "should return empty string for undefined method" do
      assert_equal [""], build(:enrollment).export("bad_method")
    end

    test "should format date for export" do
      assert_equal [Time.now.strftime("%m/%d/%y")], build(:enrollment).export("updated_at")
    end

    test "should export Y for true" do
      assert_equal %w(Y), Enrollment.new(active: true).export("active")
    end

    test "should export N for false" do
      assert_equal %w(N), Enrollment.new(active: false).export("active")
    end

    test "should handle missing associations" do
      assert_equal [""], Enrollment.new.export("status.name")
    end

    test "should handle undefined export field" do
      assert_equal ["UNDEFINED EXPORT FIELD"], Enrollment.new.export("undefined_rexport_field")
    end

    test "should export value of associated data attribute" do
      assert_equal ["The Sample Family"], build(:enrollment).export("student.family.name")
    end

    test "should export value returned from associated method" do
      assert_equal %w(bar), build(:enrollment).export("student.family.foo")
    end

    test "should export field from non rexported model" do
      assert_equal %w(active), build(:enrollment).export("status.name")
    end

    test "should export local, associated, and non rexported fields in order" do
      assert_equal(
        ["The Sample Family", "Sammy Sample", "1", "bar", "active"],
        build(:enrollment).export(
          "student.family.name",
          "student.name",
          "grade",
          "student.family.foo",
          "status.name"
        )
      )
    end
  end
end
