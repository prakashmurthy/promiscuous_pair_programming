require File.expand_path('../../spec_helper', __FILE__)
 
describe PairingSession do
  subject { Factory.build(:pairing_session) }
 
  it "should have a valid factory" do
    subject.should be_valid
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
      subject.start_at = Time.zone.now - 1.second
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
      subject.start_at = (Time.zone.now + 2.seconds)
      subject.end_at   = (Time.zone.now + 1.second)
 
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
   
  describe '.upcoming' do
    it "includes sessions which are in the future" do
      in_the_future = Factory.create(:pairing_session, :start_at => 1.hour.from_now)
      PairingSession.upcoming.should include(in_the_future)
    end
    #it "includes sessions which are in the present" do
    #  Timecop.freeze Time.zone.now
    #  in_the_present = Factory.create(:pairing_session, :start_at => Time.zone.now)
    #  PairingSession.upcoming.should include(in_the_present)
    #end
    it "excludes sessions which are in the past" do
      in_the_past = Factory.create(:pairing_session, :start_at => 1.second.from_now)
      Timecop.freeze 1.hour.from_now
      PairingSession.upcoming.should_not include(in_the_past)
    end
  end
   
  describe ".not_owned_by" do
    it "include sessions which aren't owned by the given user" do
      user1 = Factory.create(:user)
      user2 = Factory.create(:user)
      session = Factory.create(:pairing_session, :owner => user1)
      PairingSession.not_owned_by(user2).should include(session)
    end
    it "excludes sessions which are owned by the given user" do
      user1 = Factory.create(:user)
      session = Factory.create(:pairing_session, :owner => user1)
      PairingSession.not_owned_by(user1).should_not include(session)
    end
  end
   
  describe '.without_pair' do
    it "includes sessions where pair_id isn't set to anything" do
      session = Factory.create(:pairing_session, :pair => nil)
      PairingSession.without_pair.should include(session)
    end
    it "excludes sessions where pair_id is set to something" do
      user = Factory.create(:user)
      session = Factory.create(:pairing_session, :pair => user)
      PairingSession.without_pair.should_not include(session)
    end
  end
   
  describe '.location_scoped' do
    it "includes sessions which are located within the given distance around the coordinates in the given location" do
      boulder = Location.create! do |loc|
        loc.raw_location = "Boulder, CO"
        loc.lat = 40.005429
        loc.lng = -105.251126
        loc.street_address = "3205 Euclid Ave"
        loc.city = "Boulder"
        loc.province = "Boulder"
        loc.district = nil
        loc.state = "CO"
        loc.zip = 80303
        loc.country = "USA"
        loc.country_code = "US"
        loc.accuracy = 8
        loc.precision = "address"
        loc.suggested_bounds = "40.0022414,-105.2542036,40.0085366,-105.2479084"
        loc.provider = "google"
      end
      louisville = Location.create! do |loc|
        loc.raw_location = "Louisville, CO"
        loc.lat = 39.979751
        loc.lng = -105.1371
        loc.street_address = "451 499 South St"
        loc.city = "Louisville"
        loc.province = "Boulder"
        loc.district = nil
        loc.state = "CO"
        loc.zip = 80027
        loc.country = "USA"
        loc.country_code = "US"
        loc.accuracy = 8
        loc.precision = "address"
        loc.suggested_bounds = "39.9765245,-105.1403193,39.9828197,-105.1340241"
        loc.provider = "google"
      end
      session = Factory.create(:pairing_session, :location => louisville)
      PairingSession.location_scoped(:distance => 10, :around => boulder).should include(session)
    end
    it "excludes sessions which are located outside of the given distance around the coordinates in the given location" do
      boulder = Location.create! do |loc|
        loc.raw_location = "Boulder, CO"
        loc.lat = 40.005429
        loc.lng = -105.251126
        loc.street_address = "3205 Euclid Ave"
        loc.city = "Boulder"
        loc.province = "Boulder"
        loc.district = nil
        loc.state = "CO"
        loc.zip = 80303
        loc.country = "USA"
        loc.country_code = "US"
        loc.accuracy = 8
        loc.precision = "address"
        loc.suggested_bounds = "40.0022414,-105.2542036,40.0085366,-105.2479084"
        loc.provider = "google"
      end
      broomfield = Location.create! do |loc|
        loc.raw_location = "Broomfield, CO"
        loc.lat = 39.9231
        loc.lng = -105.087533
        loc.street_address = "6 Garden Center"
        loc.city = "Broomfield"
        loc.province = "Broomfield"
        loc.district = nil
        loc.state = "CO"
        loc.zip = 80020
        loc.country = "USA"
        loc.country_code = "US"
        loc.accuracy = 8
        loc.precision = "address"
        loc.suggested_bounds = "39.9202014,-105.0908036,39.9264966,-105.0845084"
        loc.provider = "google"
      end
      session = Factory.create(:pairing_session, :location => broomfield)
      PairingSession.location_scoped(:distance => 10, :around => boulder).should_not include(session)
    end
  end
   
  describe '.involving' do
    it "includes pairing sessions where the given user is the owner and someone else is the pair, or vice versa" do
      user1 = Factory.create(:user)
      user2 = Factory.create(:user)
      owner_is_user = Factory.create(:pairing_session, :owner => user1, :pair => user2)
      pair_is_user = Factory.create(:pairing_session, :owner => user2, :pair => user1)
      sessions = PairingSession.involving(user1)
      sessions.should include(owner_is_user)
      sessions.should include(pair_is_user)
    end
    it "excludes pairing sessions where the given user is neither the owner nor the pair" do
      user1, user2, user3 = Array.new(3) { Factory.create(:user) }
      session = Factory.create(:pairing_session, :owner => user2, :pair => user3)
      PairingSession.involving(user1).should_not include(session)
    end
  end
   
  describe '#partner_of' do
    before do
      @user1 = Factory.create(:user)
      @user2 = Factory.create(:user)
    end
    it "returns the pair if the owner is the given user" do
      session = Factory.create(:pairing_session, :owner => @user1, :pair => @user2)
      session.partner_of(@user1).should == @user2
    end
    it "returns the owner if the pair is the given user" do
      session = Factory.create(:pairing_session, :owner => @user2, :pair => @user1)
      session.partner_of(@user1).should == @user2
    end
  end
   
  describe '#displayed_location' do
    it "returns the location_detail if that's present" do
      subject.location_detail = "whatever"
      subject.displayed_location.should == "whatever"
    end
    it "returns the raw_location of the associated location, if that's present" do
      subject.location = Location.new(:raw_location => "whatever")
      subject.displayed_location.should == "whatever"
    end
    it "returns nil if the session doesn't have a location_detail or an associated location" do
      subject.location_detail = ""
      subject.location = nil
      subject.displayed_location.should == nil
    end
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