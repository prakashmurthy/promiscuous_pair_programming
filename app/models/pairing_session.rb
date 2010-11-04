class PairingSession < ActiveRecord::Base

  belongs_to :owner, :class_name => "User"

  validates :description, :state, :start_at, :end_at, :presence => true
  validates :state, :inclusion => %w(pending accepted declined)

  validate :starts_in_future, :if => :timestamps_set?
  validate :ends_after_start_time, :if => :timestamps_set?
  validate :no_overlapping_sessions, :if => :timestamps_set?

  default_scope order(:start_at)

  scope :upcoming, lambda { where("pairing_sessions.start_at >= ?", Time.zone.now) }
  scope :available, upcoming.where(['state <> ?', 'accepted'])

  private

  def starts_in_future
    errors.add(:start_at, "must be in the future") if start_at < Time.now
  end

  def ends_after_start_time
    errors.add(:end_at, "must be after the start time") if end_at <= start_at
  end

  def timestamps_set?
    start_at? && end_at?
  end

  def no_overlapping_sessions
    errors.add(:base, "You have already posted a session that overlaps with this one") if overlapping_sessions?
  end

  def overlapping_sessions?
    scope = owner.pairing_sessions.where([
      "(start_at <= ? AND end_at >= ?) OR (end_at >= ? AND start_at <= ?)", end_at, start_at, start_at, end_at
    ])
    scope = scope.where("id != ?", self.id) unless self.new_record?

    scope.count > 0
  end

end
