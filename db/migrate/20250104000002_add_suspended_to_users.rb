class AddSuspendedToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :suspended, :boolean, default: false
    add_column :users, :suspended_at, :datetime
    add_column :users, :suspended_by_id, :integer
    
    add_index :users, :suspended
    add_foreign_key :users, :users, column: :suspended_by_id
  end
end

