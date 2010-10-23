class CreatePairingSessions < ActiveRecord::Migration
  def self.up
    create_table :pairing_sessions do |t|
      t.string :description
      t.integer :owner_id
      t.datetime :date

      t.timestamps
    end
  end

  def self.down
    drop_table :pairing_sessions
  end
end
