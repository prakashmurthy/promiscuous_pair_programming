require File.expand_path('../../spec_helper', __FILE__)

describe PairingSession do
  subject { Factory.build(:pairing_session) }

  it "should have a valid factory" do
    subject.should be_valid
  end
  
  describe "associations" do
    it "should have an owner" do
      email         = "hello@world.com"
      owner         = Factory.build(:user, :email => email)
      subject.owner = owner
      subject.save!
      subject.reload
  
      subject.owner.email.should == email
  
    end
  end
  
  describe "validations" do
    it "should require a description" do
      subject.description = nil
  
      subject.should_not be_valid
  
      subject.description = ""
  
      subject.should_not be_valid
    end
    
    it "must be in the future" do
      subject.start_at = 1.day.ago
      subject.should_not be_valid
    end
    
    it "requires the start time" do
      subject.start_at = nil
      subject.should_not be_valid
    end
    
    it "requires the end time" do
      subject.end_at = nil
      subject.should_not be_valid
    end
    
    it "requires a start time occurring before the end time" do
      subject.start_at = 2.day.from_now
      subject.end_at = 1.day.from_now
      subject.should_not be_valid
    end
    
    it "cannot overlap with an existing request" do
      start_at = 1.day.from_now
      end_at   = 2.days.from_now
      
      user    = Factory.create(:user)
      request = Factory.create(:pairing_session, :owner => user, :start_at => start_at, :end_at => end_at)

      overlapping_request = Factory.build(:pairing_session, :owner => user, :start_at => start_at, :end_at => end_at)
      overlapping_request.should_not be_valid
    end
    
    it "considers sessions within a start / end window to be overlapping"
    it "considers sessions with an end time after the start time of another session to be overlapping"
    it "considers sessions with a start time before an end time of another session to be overlapping"
    
    it "does not consider a request from another user as overlapping" do
      start_at = 1.day.from_now
      end_at   = 2.days.from_now
      
      user1    = Factory.create(:user)
      user2    = Factory.create(:user)
      request = Factory.create(:pairing_session, :owner => user1, :start_at => start_at, :end_at => end_at)

      overlapping_request = Factory.build(:pairing_session, :owner => user2, :start_at => start_at, :end_at => end_at)
      overlapping_request.should be_valid
    end
    
      

#    it "should require a valid date" do
#      subject.meeting_date = "hello"
#      subject.should_not be_valid
#
#      subject.meeting_date = "12/40/2010"
#      subject.should_not be_valid
#    end
  end
end
