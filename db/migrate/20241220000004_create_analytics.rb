class CreateAnalytics < ActiveRecord::Migration[8.0]
  def change
    create_table :analytics do |t|
      t.references :business, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :event_data
      t.timestamps
    end
    
    add_index :analytics, [:business_id, :event_type]
    add_index :analytics, :created_at
  end
end
