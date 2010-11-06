require File.expand_path('../../spec_helper', __FILE__)

describe PairingSession do
  subject { Factory.build(:pairing_session) }

  it "sorts the sessions by start time by default" do
    second = Factory.create(:pairing_session, :start_at => 1.hour.from_now, :end_at => 2.hours.from_now)
    first  = Factory.create(:pairing_session, :start_at => 30.minutes.from_now, :end_at => 45.minutes.from_now)

    PairingSession.all.should == [first, second]
  end

  it "knows the available pairing sessions" do
    past        = Factory.build(:pairing_session, :start_at => 1.day.ago, :end_at => (1.day.ago + 1.second))
    past.save(:validate => false)

    available   = Factory.create(:pairing_session, :pair => nil)
    unavailable = Factory.create(:pairing_session, :pair => Factory.create(:user))

    PairingSession.available.should == [available]
  end

  describe "#not_owned_by" do
    it "should include sessions owned by a user" do
      me = Factory.create(:user)
      my_session = Factory.create(:pairing_session, :owner => me)
      not_my_session = Factory.create(:pairing_session)

      PairingSession.not_owned_by(me).should == [not_my_session]
    end
  end

  describe "#without_pair" do
    it "should not include sessions that have a pair" do
      pair = Factory.create(:user)
      taken_session = Factory.create(:pairing_session, :pair => pair)
      open_session = Factory.create(:pairing_session)

      PairingSession.without_pair.should == [open_session]
    end
  end
  
  describe "#sessions_where_user_is_pair" do
    it "should only show sessions where the user is the pair" do
      me = Factory.create(:user)
      my_friend = Factory.create(:user)
      my_friends_session_where_I_am_not_pairing_next_week = Factory.create(:pairing_session, :owner => my_friend, :start_at => 7.day.from_now, :end_at => 8.day.from_now)
      my_friends_session_where_I_am_pairing_in_three_days = Factory.build(:pairing_session, {
        :owner => my_friend, 
        :pair => me, 
        :start_at => 3.day.from_now, 
        :end_at => 4.day.from_now
      })
      my_friends_session_where_I_am_pairing_tomorrow = Factory.build(:pairing_session, {
        :owner => my_friend,
        :pair => me
      })
      my_friends_session_where_I_am_pairing_in_three_days.save!
      my_friends_session_where_I_am_pairing_tomorrow.save!
    
      PairingSession.sessions_where_user_is_pair(me).should == [my_friends_session_where_I_am_pairing_tomorrow, my_friends_session_where_I_am_pairing_in_three_days]
    end
  end

  describe "associations" do
    it "should have an owner" do
      user = Factory.create(:user)
      session = Factory.create(:pairing_session, :owner => user)

      session.reload.owner.should == user
    end

    it "should have a pair" do
      pair = Factory.create(:user)
      session = Factory.create(:pairing_session, :pair => pair)
      session.pair.should == pair
    end
  end

  describe "validations" do

    it "requires a valid start time"
    it "requires a valid end time"

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

    it "doesn't allow a user to accept his own pairing session" do
      user    = Factory.create(:user)
      session = Factory.build(:pairing_session, :owner => user, :pair => user)
      session.valid?

      session.errors[:base].should == ["You cannot accept your own pairing request"]
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
