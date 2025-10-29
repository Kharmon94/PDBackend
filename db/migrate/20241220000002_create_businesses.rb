class CreateBusinesses < ActiveRecord::Migration[8.0]
  def change
    create_table :businesses do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.text :description
      t.string :address, null: false
      t.string :phone
      t.string :email
      t.string :website
      t.decimal :rating, precision: 3, scale: 2, default: 0
      t.integer :review_count, default: 0
      t.string :image_url
      t.boolean :featured, default: false
      t.boolean :has_deals, default: false
      t.text :deal_description
      t.json :hours
      t.json :amenities
      t.json :gallery
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    
    add_index :businesses, :category
    add_index :businesses, :featured
    add_index :businesses, :has_deals
  end
end
