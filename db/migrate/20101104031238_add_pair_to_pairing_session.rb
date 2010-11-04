class AddPairToPairingSession < ActiveRecord::Migration
  def self.up
    add_column :pairing_sessions, :pair_id, :integer
  end

  def self.down
    remove_column :pairing_sessions, :pair_id
  end
end
