class MakeLocationIdNullable < ActiveRecord::Migration
  def self.up
    change_column :users, :location_id, :integer, :null => true
    change_column :pairing_sessions, :location_id, :integer, :null => true
  end

  def self.down
    change_column :users, :location_id, :integer, :null => false
    change_column :pairing_sessions, :location_id, :integer, :null => false
  end
end
