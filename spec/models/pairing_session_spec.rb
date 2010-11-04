require File.expand_path('../../spec_helper', __FILE__)

describe PairingSession do
  subject { Factory.build(:pairing_session) }

  it "sorts the sessions by start time by default" do
    session_1 = Factory.create(:pairing_session, :start_at => 1.hour.from_now, :end_at => 2.hours.from_now)
    session_2 = Factory.create(:pairing_session, :start_at => 30.minutes.from_now, :end_at => 45.minutes.from_now)
    
    PairingSession.all.should == [session_2, session_1]
  end

  it "knows the available pairing sessions" do
    past        = Factory.build(:pairing_session, :start_at => 1.day.ago, :end_at => (1.day.ago + 1.second))
    past.save(:validate => false)

    available   = Factory.create(:pairing_session, :state => 'pending')
    unavailable = Factory.create(:pairing_session, :state => 'accepted')

    PairingSession.available.should == [available]
  end

  describe "associations" do
    it "should have an owner" do
      user = Factory.create(:user)
      session = Factory.create(:pairing_session, :owner => user)

      session.reload.owner.should == user
    end
  end

  describe "validations" do

    it "requires a valid start time"
    it "requires a valid end time"

    it "requires a state" do
      subject.state = nil
      subject.valid?

      subject.errors[:state].should_not be_empty
    end

    %w(pending accepted declined).each do |state|
      it "allows #{state} as a state" do
        subject.state = state
        subject.valid?

        subject.errors[:state].should be_empty
      end
    end

    it "does not allow an unknown state" do
      subject.state = 'bogus'
      subject.valid?

      subject.errors[:state].should_not be_empty
    end

    it "should require a description" do
      subject.description = ''
      subject.valid?

      subject.errors[:description].should_not be_nil
    end

    it "must have a start time in the future" do
      subject.start_at = Time.now - 1.second
      subject.valid?

      subject.errors[:start_at].should_not be_nil
    end

    it "requires the start time" do
      subject.start_at = nil
      subject.valid?

      subject.errors[:start_at].should_not be_nil
    end

    it "requires the end time" do
      subject.end_at = nil
      subject.valid?

      subject.errors[:end_at].should_not be_nil
    end

    it "requires a end time occurring after the start time" do
      subject.start_at = (Time.now + 2.seconds)
      subject.end_at   = (Time.now + 1.second)

      subject.valid?

      subject.errors[:end_at].should == ["must be after the start time"]
    end

    context "with an existing pairing session" do
      before do
        @user    = Factory.create(:user)
        @session = Factory.create(:pairing_session, :owner => @user)
      end

      it "knows that a session after the existing one does not overlap" do
        other_session = Factory.build(:pairing_session, {
          :owner    => @user,
          :start_at => (@session.end_at + 1.second),
          :end_at   => (@session.end_at + 2.seconds)

        })
        other_session.should be_valid
      end

      it "knows that a session before the existing one does not overlap" do
        other_request = Factory.build(:pairing_session, {
          :owner    => @user,
          :start_at => (@session.start_at - 2.seconds),
          :end_at   => (@session.start_at - 1.second)

        })
        other_request.should be_valid
      end

      it "knows that another session with the same times is overlapping" do
        overlapping_session = Factory.build(:pairing_session, {
          :owner    => @user,
          :start_at => @session.start_at,
          :end_at   => @session.end_at
        })
        overlapping_session.should_not be_valid
      end

      it "knows that a session inside the window of an existing session is overlapping" do
        overlapping_session = Factory.build(:pairing_session, {
          :owner    => @user,
          :start_at => @session.start_at + 1.second,
          :end_at   => @session.end_at - 1.second
        })
        overlapping_session.should_not be_valid
      end

      it "considers sessions with an end time after the start time of another session to be overlapping" do
        overlapping_session = Factory.build(:pairing_session, {
          :owner    => @user,
          :start_at => @session.start_at - 2.seconds,
          :end_at   => @session.start_at + 1.second
        })
        overlapping_session.should_not be_valid
      end

      it "considers sessions with a start time before an end time of another session to be overlapping" do
        overlapping_session = Factory.build(:pairing_session, {
          :owner    => @user,
          :start_at => @session.end_at - 1.second,
          :end_at   => @session.end_at + 2.seconds
        })
        overlapping_session.should_not be_valid
      end

      it "should not consider the pairing session that we are editing when looking for time overlap" do
        new_end_at = @session.end_at - 1.hour
        @session.end_at = new_end_at
        @session.should be_valid
      end

      it "does not consider a session from another user as overlapping" do
        other_user    = Factory.create(:user)
        other_session = Factory.build(:pairing_session, {
          :owner    => other_user,
          :start_at => @session.start_at,
          :end_at   => @session.end_at
        })
        other_session.should be_valid
      end
    end
  end
end
