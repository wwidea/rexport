# frozen_string_literal: true

require "rails"
require "active_record"
require "rexport"

require "factory_bot"
require "mocha/minitest"
require File.expand_path("../test/factories", __dir__)

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods
    include Rexport::Factories

    def setup
      ActiveRecord::Migration.suppress_messages { setup_db }
      Enrollment.instance_variable_set(:@rexport_fields, nil)
      Student.instance_variable_set(:@rexport_fields, nil)
    end

    def teardown
      teardown_db
    end

    private

    def setup_db # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      ActiveRecord::Schema.define(version: 1) do
        create_table :enrollments do |t|
          t.integer :student_id, :status_id, :grade
          t.boolean :active
          t.timestamps
        end

        create_table :students do |t|
          t.integer :family_id
          t.string :name
          t.date :date_of_birth
          t.timestamps
        end

        create_table :families do |t|
          t.string :name
          t.timestamps
        end

        create_table :statuses do |t|
          t.string :name
        end

        create_table :exports do |t|
          t.string :name
          t.string :model_class_name
          t.text :description
        end

        create_table :export_items do |t|
          t.integer :export_id
          t.string :name, :rexport_field
          t.integer :position
        end

        create_table :export_filters do |t|
          t.integer :export_id
          t.string :filter_field, :value
        end

        create_table :self_referential_checks do |t| # rubocop:disable Lint/EmptyBlock
          # this is a comment
        end
      end
    end

    def teardown_db
      ActiveRecord::Base.connection.data_sources.each do |table|
        ActiveRecord::Base.connection.drop_table(table)
      end
    end
  end
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.acts_as_list(_options = {}); end
end

class Enrollment < ApplicationRecord
  include Rexport::DataFields
  belongs_to :student
  belongs_to :status
  belongs_to :ilp_status, class_name: "Status"
  belongs_to :self_referential_check

  def self.initialize_local_rexport_fields(rexport_model)
    rexport_model.add_rexport_field(:foo_method, method: :foo)
    rexport_model.add_rexport_field(:bad_method, method: "bad_method")
    rexport_model.add_association_methods(associations: %w[status ilp_status])
  end

  def foo
    "bar"
  end
end

class Student < ApplicationRecord
  include Rexport::DataFields
  belongs_to :family
  has_many :enrollments

  def self.find_family_for_rexport
    Family.order(:name)
  end
end

class Family < ApplicationRecord
  include Rexport::DataFields
  has_many :students

  def self.initialize_local_rexport_fields(rexport_model)
    rexport_model.add_rexport_field(:foo_method, method: :foo)
  end

  def foo
    "bar"
  end
end

class Status < ApplicationRecord
  # does not include Rexport
  has_many :enrollments
end

class Export < ApplicationRecord
  include Rexport::ExportMethods
end

class ExportItem < ApplicationRecord
  include Rexport::ExportItemMethods
end

class ExportFilter < ApplicationRecord
  include Rexport::ExportFilterMethods
end

class SelfReferentialCheck < ApplicationRecord
  include Rexport::DataFields
  belongs_to :enrollment
end
