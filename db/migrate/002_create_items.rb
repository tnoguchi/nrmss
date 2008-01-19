class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :url
      t.string :user_description
      t.integer :rms_type
      t.string :name
      t.text :description
      t.integer :price
      t.integer :amount
      t.timestamp :created_at
      t.timestamp :updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
