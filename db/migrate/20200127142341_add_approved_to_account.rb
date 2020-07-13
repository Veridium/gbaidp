class AddApprovedToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :approved, :boolean, :default => false
  end
end
