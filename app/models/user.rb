class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :trackable, :rememberable, :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable

  validates :first_name, :last_name, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation#, :remember_me

  has_many :owned_pairing_sessions, :class_name => "PairingSession", :foreign_key => :owner_id
  has_many :pairing_sessions_as_pair, :class_name => "PairingSession", :foreign_key => :pair_id

  def full_name
    "#{first_name} #{last_name}"
  end
end
