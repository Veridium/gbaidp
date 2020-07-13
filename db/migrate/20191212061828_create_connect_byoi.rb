class CreateConnectByoi < ActiveRecord::Migration
    def self.up
      create_table :connect_byois do |t|
        t.belongs_to :account
        t.timestamps
      end
    end
  
    def self.down
      drop_table :connect_byois
    end
  end
  