class CreateAssigns < ActiveRecord::Migration
  def self.up
    create_table :assigns do |t|
      t.integer  "group_id"
      t.integer  "item_id"

      t.timestamps
    end
  end

  def self.down
    drop_table :assigns
  end
end
