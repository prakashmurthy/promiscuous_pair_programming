class PairingSession < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  belongs_to :pair, :class_name => "User"
  belongs_to :location

  validates :description, :start_at, :end_at, :presence => true

  validate :starts_in_future, :if => :timestamps_set?
  validate :ends_after_start_time, :if => :timestamps_set?
  validate :no_overlapping_sessions, :if => :timestamps_set?

  validate :pair_is_not_owner
  
  # If a pairing session is saved with :enable_geocoding => true,
  # the raw_location will be run through the Google Maps API, resulting in a
  # Location record which will be tied to the pairing session via location_id.
  #
  # (Please list this after existing validations so the validation this
  # introduces goes last.)
  #
  include PPP::ModelMixins::Geocoding
  auto_geocode_location

  scope :upcoming, lambda { where(:start_at.gte => Time.now.utc) }
  scope :not_owned_by, lambda {|user| where(:owner_id.ne => user.id) }
  scope :without_pair, where(:pair_id => nil)
  scope :location_scoped, lambda {|options|
    geo_scope(:within => options[:distance], :origin => options[:around].coordinates).
    includes(:location)
  }
  scope :involving, lambda {|user|
    where({:owner_id.eq => user.id, :pair_id.ne => nil} | {:pair_id.eq => user.id})
  }
  
  # Compound scopes
  scope :available, lambda { upcoming.without_pair }  # have to wrap this in a lambda since .upcoming depends on the current time
  scope :available_to, lambda {|user| available.not_owned_by(user) }
  
  def partner_of(user)
    owner_id == user.id ? pair : owner
  end
  
  def displayed_location
    location_detail.presence || location.try(:raw_location)
  end

private
  def starts_in_future
    errors.add(:start_at, "must be in the future") if start_at < Time.zone.now
  end

  def ends_after_start_time
    errors.add(:end_at, "must be after the start time") if end_at <= start_at
  end

  def timestamps_set?
    start_at.present? && end_at.present?
  end

  def no_overlapping_sessions
    errors.add(:base, "You have already posted a session that overlaps with this one") if overlapping_sessions?
  end

  def pair_is_not_owner
    errors.add(:base, "You cannot accept your own pairing request") if pair == owner
  end

  def overlapping_sessions?
    scope = owner.owned_pairing_sessions.where([
      "(start_at <= ? AND end_at >= ?) OR (end_at >= ? AND start_at <= ?)", end_at, start_at, start_at, end_at
    ])
    scope = scope.where("id != ?", self.id) unless self.new_record?

    scope.count > 0
  end
end
# == Schema Information
#
# Table name: pairing_sessions
#
#  id              :integer         not null, primary key
#  description     :string(255)
#  owner_id        :integer
#  created_at      :datetime
#  updated_at      :datetime
#  start_at        :datetime        not null
#  end_at          :datetime        not null
#  pair_id         :integer
#  location_id     :integer
#  location_detail :string(255)
#

