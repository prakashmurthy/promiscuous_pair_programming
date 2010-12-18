class AddConfirmableToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.confirmable
    end
    add_index :users, :confirmation_token,   :unique => true
  end

  def self.down
    remove_column :users, :confirmable
    remove_index :users, :confirmation_token
  end
end
