require 'test/unit'
require 'rubygems'
require 'active_record'
require 'active_support/test_case'
require 'logger'
require 'factory_girl'
require File.dirname(__FILE__) + '/factories'
require File.dirname(__FILE__) + '/../lib/rexport/data_fields'
require File.dirname(__FILE__) + '/../lib/rexport/export_methods'
require File.dirname(__FILE__) + '/../lib/rexport/export_item_methods'
require File.dirname(__FILE__) + '/../lib/rexport/export_filter_methods'
require File.dirname(__FILE__) + '/../lib/rexport/tree_node'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

RAILS_DEFAULT_LOGGER = Logger.new(File.dirname(__FILE__) + '/log/test.log')
RAILS_DEFAULT_LOGGER.level = Logger::DEBUG
ActiveRecord::Base.logger = RAILS_DEFAULT_LOGGER

class ActiveSupport::TestCase
  include Rexport::Factories

  def setup
    setup_db
    Enrollment.instance_variable_set('@rexport_fields', nil)
    Student.instance_variable_set('@rexport_fields', nil)
  end

  def teardown
    teardown_db
  end

  # Placeholder so test/unit ignores test cases without any tests.
  def default_test
  end

  private

  def setup_db
    old_stdout = $stdout
    $stdout = StringIO.new

    ActiveRecord::Schema.define(:version => 1) do
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
        t.string :model_name
        t.string :built_in_key
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

    $stdout = old_stdout
  end

  def teardown_db
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
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
  belongs_to :ilp_status, :class_name => 'Status', :foreign_key => 'ilp_status_id'
  belongs_to :self_referential_check

  def foo
    'bar'
  end

  private

  def Enrollment.initialize_local_rexport_fields
    add_rexport_field(:foo_method, :method => :foo)
    add_rexport_field(:bad_method, :method => 'bad_method')
    add_association_methods(:associations => %w(status ilp_status))
  end
end

class Student < ActiveRecord::Base
  include Rexport::DataFields
  belongs_to :family
  has_many :enrollments
end

class Family < ActiveRecord::Base
  include Rexport::DataFields
  has_many :students

  def foo
    'bar'
  end

  private

  def Family.initialize_local_rexport_fields
    add_rexport_field(:foo_method, :method => :foo)
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
  belongs_to :enrollment

  def SelfReferentialCheck.rexport_fields
    'trick get_rexport_models into believing we are exportable'
  end
end
