class CreateWhiteLabels < ActiveRecord::Migration[8.0]
  def change
    create_table :white_labels do |t|
      t.references :user, null: false, foreign_key: true
      t.string :domain
      t.string :subdomain
      t.string :brand_name
      t.string :logo_url
      t.string :primary_color
      t.string :secondary_color
      t.text :custom_css
      t.json :settings

      t.timestamps
    end
    
    add_index :white_labels, :domain, unique: true
    add_index :white_labels, :subdomain, unique: true
  end
end

