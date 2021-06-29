require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rails"
require 'active_record'
require "rexport"

require 'minitest/autorun'
require 'factory_bot'
require 'mocha/minitest'
require File.dirname(__FILE__) + '/factories'

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include Rexport::Factories

  def setup
    suppress_output { setup_db }
    Enrollment.instance_variable_set('@rexport_fields', nil)
    Student.instance_variable_set('@rexport_fields', nil)
  end

  def teardown
    teardown_db
  end

  private

  def setup_db
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

      create_table :self_referential_checks do |t|
      end
    end
  end

  def teardown_db
    ActiveRecord::Base.connection.data_sources.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  def suppress_output
    original_stdout = $stdout.clone
    $stdout.reopen File.new('/dev/null', 'w')
    yield
  ensure
    $stdout.reopen original_stdout
  end
end

class ActiveRecord::Base
  class << self
    def acts_as_list(options = {})
    end
  end
end

class Enrollment < ActiveRecord::Base
  include Rexport::DataFields
  belongs_to :student
  belongs_to :status
  belongs_to :ilp_status, class_name: 'Status', foreign_key: 'ilp_status_id'
  belongs_to :self_referential_check

  def foo
    'bar'
  end

  private

  def self.initialize_local_rexport_fields(rexport_model)
    rexport_model.add_rexport_field(:foo_method, method: :foo)
    rexport_model.add_rexport_field(:bad_method, method: 'bad_method')
    rexport_model.add_association_methods(associations: %w(status ilp_status))
  end
end

class Student < ActiveRecord::Base
  include Rexport::DataFields
  belongs_to :family
  has_many :enrollments

  def self.find_family_for_rexport
    Family.order(:name)
  end
end

class Family < ActiveRecord::Base
  include Rexport::DataFields
  has_many :students

  def foo
    'bar'
  end

  private

  def self.initialize_local_rexport_fields(rexport_model)
    rexport_model.add_rexport_field(:foo_method, method: :foo)
  end
end

class Status < ActiveRecord::Base
  # does not include Rexport
  has_many :enrollments
end

class Export < ActiveRecord::Base
  include Rexport::ExportMethods
end

class ExportItem < ActiveRecord::Base
  include Rexport::ExportItemMethods
end

class ExportFilter < ActiveRecord::Base
  include Rexport::ExportFilterMethods
end

class SelfReferentialCheck < ActiveRecord::Base
  include Rexport::DataFields
  belongs_to :enrollment
end
