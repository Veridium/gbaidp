class AddEmailToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :email, :string, :null => true, :default => nil
  end
end
