class PairingSession < ActiveRecord::Base

  belongs_to :owner, :class_name => "User"

  validates :description, :presence => true
  
  validate :starts_in_future
  validate :ends_after_start_time
  validate :no_overlap_between_sessions  
  
  private
  
  def starts_in_future
    errors.add(:start_at, "must be in the future") if start_at < Time.now
  end
  
  def ends_after_start_time
    errors.add(:end_at, "must be after the start time") if end_at <= start_at
  end
  
  def no_overlap_between_sessions
    count = owner.pairing_sessions.count(:conditions => {:start_at => start_at, :end_at => end_at})
    errors.add(:base, "You have already posted a session that overlaps with this one") if count > 0
  end
  
end
