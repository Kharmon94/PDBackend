class CreateSavedDeals < ActiveRecord::Migration[8.0]
  def change
    create_table :saved_deals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :business, null: false, foreign_key: true
      t.timestamps
    end
    
    add_index :saved_deals, [:user_id, :business_id], unique: true
  end
end
