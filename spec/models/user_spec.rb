require File.expand_path('../../spec_helper', __FILE__)

describe User do

  subject {Factory.build(:user)}

  it "should have a valid factory" do
    subject.should be_valid
  end

  it "should have many owned pairing sessions" do
    user            = Factory.create(:user)
    pairing_session = Factory.create(:pairing_session, :owner => user)

    user.owned_pairing_sessions.should == [pairing_session]
  end

  it "knows about the sessions that it is the pair for" do
    user            = Factory.create(:user)
    pairing_session = Factory.create(:pairing_session, :pair => user)

    user.pairing_sessions_as_pair.should == [pairing_session]
  end

  it "returns a full name based on first and last name" do
    user = Factory.build(:user, :first_name => 'Richard', :last_name => "Nixon")
    user.full_name.should == "Richard Nixon"
  end

end
