require 'spec_helper'

describe User do

  subject {Factory.build(:user)}

  it "should have a valid factory" do
    subject.should be_valid
  end

  it "should have many pairing sessions" do
    @pairing_session = Factory.build(:pairing_session)
    subject.pairing_sessions << @pairing_session
    subject.save!
    subject.reload

    subject.pairing_sessions.should eq([@pairing_session])

  end
end
