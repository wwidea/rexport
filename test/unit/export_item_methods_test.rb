require 'test_helper'

class ExportItemMethodsTest < ActiveSupport::TestCase
  test 'should resort export items' do
    export = FactoryBot.create(:export)
    ExportItem.resort(export.export_items.ordered.reverse.map(&:id).map(&:to_s))
    assert_equal 'Bogus Item', export.export_items.ordered.first.name
  end
end
