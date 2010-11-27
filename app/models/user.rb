class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :trackable, :rememberable, :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation#, :remember_me

  has_many :owned_pairing_sessions, :class_name => "PairingSession", :foreign_key => :owner_id
  has_many :pairing_sessions_as_pair, :class_name => "PairingSession", :foreign_key => :pair_id
  belongs_to :location

  validates :first_name, :last_name, :presence => true

  # Ensure this is listed after existing validations so the validation this introduces goes last
  # Also ensure this is below the attr_accessible above since this will add raw_location
  # to the accessible attributes if any are present
  include PPP::ModelMixins::Geocoding
  auto_geocode_location

  def full_name
    "#{first_name} #{last_name}"
  end
  
  # Don't require the password confirmation for an existing user, if password is left blank.
  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-account-without-providing-a-password
  def update_with_password(params={})
    if !new_record? && params[:password].blank? 
      params.delete(:password) 
      params.delete(:password_confirmation) if params[:password_confirmation].blank? 
    end 
    update_attributes(params) 
  end
end

# == Schema Information
#
# Table name: users
#
#  id                   :integer         not null, primary key
#  email                :string(255)     default(""), not null
#  encrypted_password   :string(128)     default(""), not null
#  password_salt        :string(255)     default(""), not null
#  reset_password_token :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  first_name           :string(255)
#  last_name            :string(255)
#  location_id          :integer
#

