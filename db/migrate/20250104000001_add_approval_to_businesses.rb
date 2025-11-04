class AddApprovalToBusinesses < ActiveRecord::Migration[8.0]
  def change
    add_column :businesses, :approval_status, :string, default: 'approved'
    add_column :businesses, :approved_at, :datetime
    add_column :businesses, :approved_by_id, :integer
    
    add_index :businesses, :approval_status
    add_foreign_key :businesses, :users, column: :approved_by_id
  end
end

