class AddDurationToPairingSessions < ActiveRecord::Migration
  def self.up
    change_table :pairing_sessions do |t|
      t.remove :date
      t.datetime :start_at, :end_at, :null => false
    end
  end

  def self.down
    change_table :pairing_sessions do |t|
      t.remove :start_at, :end_at
      t.datetime :date
    end
  end
end
