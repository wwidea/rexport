# frozen_string_literal: true

require 'test_helper'

class ExportFilterMethodsTest < ActiveSupport::TestCase
  test 'should return associated object name' do
    assert_equal '1', FactoryBot.create(:grade_filter).display_value
  end

  test 'should return chained associated object value' do
    assert_equal 'active', FactoryBot.create(:status_filter).display_value
  end

  test 'should return chained associated object' do
    family = FactoryBot.create(:family)
    assert_equal(
      family.name,
      export_filter('student.family_id', value: family.id).display_value
    )
  end

  test 'should return undefined association' do
    assert_equal('UNDEFINED ASSOCIATION', export_filter('bogus_id').display_value)
  end

  test 'should return associated object not found' do
    assert_equal 'ASSOCIATED OBJECT NOT FOUND', export_filter('status_id').display_value
  end

  private

  def export_filter(filter_field, value: 1)
    ExportFilter.new(
      export:       FactoryBot.create(:export),
      filter_field: filter_field,
      value:        value
    )
  end
end
