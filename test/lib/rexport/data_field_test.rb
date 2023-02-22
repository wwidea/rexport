# frozen_string_literal: true

require "test_helper"

class DataFieldTest < ActiveSupport::TestCase
  test "should stringify name" do
    assert_equal "foo", Rexport::DataField.new(:foo).name
  end

  test "should use name for method" do
    assert_equal "foo", Rexport::DataField.new(:foo).method
  end

  test "should save method" do
    assert_equal "bar", Rexport::DataField.new(:foo, method: :bar).method
  end

  test "should save type" do
    assert_equal :type_test, Rexport::DataField.new(:test, type: :type_test).type
  end

  test "should_sort_data_fields" do
    a = Rexport::DataField.new(:a)
    b = Rexport::DataField.new(:b)

    assert_equal [a, b], [b, a].sort
  end
end
