# frozen_string_literal: true

require "test_helper"

class ExportItemMethodsTest < ActiveSupport::TestCase
  test "should resort export items" do
    export = FactoryBot.create(:export)
    ExportItem.resort(export.export_items.ordered.reverse.map(&:to_param))

    assert_equal "Bogus Item", export.export_items.ordered.first.name
  end

  test "should return attributes_for_copy" do
    assert FactoryBot.create(:family_name_export_item).attributes_for_copy
  end

  test "should set name when blank" do
    assert_equal "Grade", FactoryBot.create(:grade_export_item).name
  end

  test "should set name for chained field to last two items" do
    assert_equal "Name - Test", ExportItem.create(rexport_field: "this.is.a.name.test").name
  end
end
