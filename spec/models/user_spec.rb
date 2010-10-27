require File.expand_path('../../spec_helper', __FILE__)

describe User do

  subject {Factory.build(:user)}

  it "should have a valid factory" do
    subject.should be_valid
  end

  it "should have many pairing sessions" do
    user            = Factory.create(:user)
    pairing_session = Factory.create(:pairing_session, :owner => user)

    user.pairing_sessions.should == [pairing_session]
  end
end
