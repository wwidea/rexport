require 'test_helper'

class DataFieldTest < ActiveSupport::TestCase
  def test_should_stringify_name
    assert_equal('foo', Rexport::DataField.new(:foo).name)
  end

  def test_should_use_name_for_method
    assert_equal('foo', Rexport::DataField.new(:foo).method)
  end

  def test_should_save_method
    assert_equal('bar', Rexport::DataField.new(:foo, :method => :bar).method)
  end

  def test_should_save_type
    assert_equal(:type_test, Rexport::DataField.new(:test, :type => :type_test).type)
  end

  def test_should_sort_data_fields
    a = Rexport::DataField.new(:a)
    b = Rexport::DataField.new(:b)
    assert_equal([a,b], [b,a].sort)
  end
end