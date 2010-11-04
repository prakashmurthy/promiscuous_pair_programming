class AddStateToPairingSessions < ActiveRecord::Migration
  def self.up
    add_column :pairing_sessions, :state, :string, :null => false, :default => 'pending'
  end

  def self.down
    remove_column :pairing_sessions, :state
  end
end
