class PairingSession < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  belongs_to :pair, :class_name => "User"
  belongs_to :location

  validates :description, :start_at, :end_at, :presence => true

  validate :starts_in_future, :if => :timestamps_set?
  validate :ends_after_start_time, :if => :timestamps_set?
  validate :no_overlapping_sessions, :if => :timestamps_set?

  validate :pair_is_not_owner
  
  # Ensure this is listed after existing validations so the validation this introduces goes last
  include PPP::ModelMixins::Geocoding
  auto_geocode_location

  default_scope order(:start_at)

  scope :upcoming, lambda { where("pairing_sessions.start_at >= ?", Time.zone.now) }
  scope :not_owned_by, lambda {|user| where('owner_id != ?', user.id) }
  scope :without_pair, where('pair_id IS NULL')
  # Have to wrap this in a lambda since .upcoming depends on the current time
  scope :available, lambda { upcoming.without_pair }

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

