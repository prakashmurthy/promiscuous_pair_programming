class AddLocationToPairingSessionsAndUsers < ActiveRecord::Migration
  def self.up
    create_table :locations, :force => true do |t|
      t.string  :raw_location, :null => false
      t.float   :lat, :null => false
      t.float   :lng, :null => false
      t.string  :street_address#, :null => false
      t.string  :city, :null => false
      t.string  :province, :null => false
      t.string  :district#, :null => false
      t.string  :state, :null => false
      t.string  :zip#, :null => false
      t.string  :country, :null => false
      t.string  :country_code, :null => false
      t.integer :accuracy, :null => false
      t.string  :precision, :null => false
      t.string  :suggested_bounds, :null => false
      t.string  :provider, :null => false
      t.timestamps
    end
    
    add_column :users, :location_id, :integer, :null => false
    
    add_column :pairing_sessions, :location_id, :integer, :null => false
    add_column :pairing_sessions, :location_detail, :string
  end

  def self.down
    drop_table :locations
    
    remove_column :users, :location_id
    
    remove_column :pairing_sessions, :location_id
    remove_column :pairing_sessions, :location_detail
  end
end
