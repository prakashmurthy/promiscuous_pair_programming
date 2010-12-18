class RemoveLocationIdFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :location_id
  end

  def self.down
    add_column :users, :location_id, :integer
  end
end
