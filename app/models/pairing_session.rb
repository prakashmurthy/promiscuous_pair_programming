class PairingSession < ActiveRecord::Base
  validates :description, :presence => true
  belongs_to :owner, :class_name => "User"
end
