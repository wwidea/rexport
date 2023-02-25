# frozen_string_literal: true

require "test_helper"

class FormatterTest < ActiveSupport::TestCase
  test "should convert date" do
    assert_equal "12/25/96", convert(Date.parse("1996-12-25"))
  end

  test "should convert time" do
    assert_equal "12/13/05", convert(Date.parse("2005-12-13").to_time)
  end

  test "should convert true to Y" do
    assert_equal "Y", convert(true)
  end

  test "should convert false to N" do
    assert_equal "N", convert(false)
  end

  test "should return empty string for nil" do
    assert_equal "", convert(nil)
  end

  private

  def convert(value)
    Rexport::Formatter.convert(value)
  end
end
