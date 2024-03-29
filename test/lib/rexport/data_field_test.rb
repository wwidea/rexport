# frozen_string_literal: true

require "test_helper"

class DataFieldTest < ActiveSupport::TestCase
  test "should stringify name" do
    assert_equal "foo", data_field.name
  end

  test "should use name for method" do
    assert_equal "foo", data_field.method
  end

  test "should save method" do
    assert_equal "bar", data_field(method: :bar).method
  end

  test "should save type" do
    assert_equal :type_test, data_field(type: :type_test).type
  end

  test "should_sort_data_fields" do
    assert_equal %w[a b], [data_field(name: :b), data_field(name: :a)].sort.map(&:name)
  end

  test "should return first assocation from method chain for association_name" do
    assert_equal "assocation_one", data_field(method: "assocation_one.assocation_two.method").association_name
  end

  test "should return nil for association_name when no dot operator is present" do
    assert_nil data_field(method: "method").association_name
  end

  private

  def data_field(name: :foo, method: nil, type: nil)
    Rexport::DataField.new(name, method: method, type: type)
  end
end
