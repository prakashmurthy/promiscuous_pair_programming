require File.expand_path('../../spec_helper', __FILE__)

describe PairingSession do
  subject { Factory.build(:pairing_session) }

  it "should have a valid factory" do
    subject.should be_valid
  end

  it "sorts the sessions by start time by default" do
    second = Factory.create(:pairing_session, :start_at => 1.hour.from_now, :end_at => 2.hours.from_now)
    first  = Factory.create(:pairing_session, :start_at => 30.minutes.from_now, :end_at => 45.minutes.from_now)

    PairingSession.all.should == [first, second]
  end

  describe '.available' do
    it "only includes sessions which are upcoming" do
      Timecop.freeze Time.local(2010, 1, 1)
      in_the_past = Factory.create(:pairing_session, :start_at => Time.local(2010, 1, 1))
      Timecop.freeze Time.local(2010, 1, 2)
      in_the_present = Factory.create(:pairing_session, :start_at => Time.local(2010, 1, 2))
      in_the_future = Factory.create(:pairing_session, :start_at => Time.local(2010, 1, 3))

      availables = PairingSession.available
      availables.should include(in_the_present)
      availables.should include(in_the_future)
      availables.should_not include(in_the_past)
    end
    it "only includes sessions which are without a pair" do
      without_a_pair = Factory.create(:pairing_session, :pair => nil)
      with_a_pair = Factory.create(:pairing_session, :pair => Factory.create(:user))
      
      availables = PairingSession.available
      availables.should include(without_a_pair)
      availables.should_not include(with_a_pair)
    end
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
    it_behaves_like "a location-based model: validations"

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
        # XXX: Is there a better way to test this?
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
  
  context "on create" do
    it_behaves_like "a location-based model: create callbacks"
  end
  
  context "on update" do
    subject { Factory.create(:pairing_session) }
    it_behaves_like "a location-based model: update callbacks"
  end
  
  it_behaves_like "a location-based model"
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

