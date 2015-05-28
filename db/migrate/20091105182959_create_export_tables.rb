class CreateExportTables < ActiveRecord::Migration
  def self.up
    create_table "export_filters", :force => true do |t|
      t.integer  "export_id"
      t.string   "field"
      t.string   "value"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "export_items", :force => true do |t|
      t.integer  "export_id"
      t.integer  "position"
      t.string   "name"
      t.string   "rexport_field"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "exports", :force => true do |t|
      t.string   "name"
      t.string   "model_class_name"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :export_filters
    drop_table :export_items
    drop_table :exports
  end
end
